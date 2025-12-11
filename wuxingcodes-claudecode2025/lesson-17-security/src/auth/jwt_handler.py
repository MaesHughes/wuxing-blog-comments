"""
JWT Token Handler - 生产级JWT令牌管理系统

功能特性：
- JWT生成和验证
- Token黑名单机制
- 刷新Token支持
- 设备指纹验证
- 多客户端支持

作者：大熊掌门
版本：1.0.0
"""

from datetime import datetime, timedelta
from typing import Optional, Dict, Any, List
import jwt
import redis
from functools import wraps
from fastapi import HTTPException, status, Request
from pydantic import BaseModel
import uuid
import hashlib
import logging

logger = logging.getLogger(__name__)


class TokenData(BaseModel):
    """Token数据模型"""
    user_id: str
    username: str
    roles: List[str]
    permissions: List[str]
    device_id: Optional[str] = None
    token_type: str = "access"


class JWTHandler:
    """JWT令牌处理器"""

    def __init__(
        self,
        secret_key: str,
        algorithm: str = "HS256",
        access_token_expire_minutes: int = 30,
        refresh_token_expire_days: int = 7,
        redis_client: Optional[redis.Redis] = None
    ):
        """
        初始化JWT处理器

        Args:
            secret_key: JWT密钥
            algorithm: 加密算法
            access_token_expire_minutes: 访问令牌过期时间（分钟）
            refresh_token_expire_days: 刷新令牌过期时间（天）
            redis_client: Redis客户端（用于黑名单）
        """
        self.secret_key = secret_key
        self.algorithm = algorithm
        self.access_token_expire_minutes = access_token_expire_minutes
        self.refresh_token_expire_days = refresh_token_expire_days
        self.redis_client = redis_client

        # Token黑名单键前缀
        self.blacklist_prefix = "jwt:blacklist:"
        self.refresh_token_prefix = "jwt:refresh:"

    def create_access_token(
        self,
        data: Dict[str, Any],
        expires_delta: Optional[timedelta] = None,
        device_id: Optional[str] = None
    ) -> str:
        """
        创建访问令牌

        Args:
            data: 要编码的数据
            expires_delta: 自定义过期时间
            device_id: 设备ID

        Returns:
            JWT token string
        """
        to_encode = data.copy()

        # 设置过期时间
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=self.access_token_expire_minutes)

        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow(),
            "type": "access",
            "jti": str(uuid.uuid4()),  # JWT ID for revocation
        })

        # 添加设备信息
        if device_id:
            to_encode["device_id"] = device_id

        # 创建token
        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)

        # 记录活跃token
        if self.redis_client:
            key = f"jwt:active:{to_encode['jti']}"
            self.redis_client.setex(
                key,
                self.access_token_expire_minutes * 60,
                encoded_jwt
            )

        logger.info(f"Created access token for user {data.get('user_id')}")
        return encoded_jwt

    def create_refresh_token(
        self,
        data: Dict[str, Any],
        device_id: Optional[str] = None
    ) -> str:
        """
        创建刷新令牌

        Args:
            data: 要编码的数据
            device_id: 设备ID

        Returns:
            JWT refresh token string
        """
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(days=self.refresh_token_expire_days)

        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow(),
            "type": "refresh",
            "jti": str(uuid.uuid4()),
        })

        if device_id:
            to_encode["device_id"] = device_id

        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)

        # 存储刷新token
        if self.redis_client:
            key = f"{self.refresh_token_prefix}{to_encode['jti']}"
            self.redis_client.setex(
                key,
                self.refresh_token_expire_days * 24 * 3600,
                encoded_jwt
            )

        logger.info(f"Created refresh token for user {data.get('user_id')}")
        return encoded_jwt

    def verify_token(self, token: str, token_type: str = "access") -> Dict[str, Any]:
        """
        验证令牌

        Args:
            token: JWT令牌
            token_type: 令牌类型（access/refresh）

        Returns:
            解码后的数据

        Raises:
            HTTPException: 令牌无效
        """
        try:
            # 解码token
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])

            # 检查token类型
            if payload.get("type") != token_type:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token type"
                )

            # 检查是否在黑名单中
            if self.redis_client and self.is_token_blacklisted(payload.get("jti")):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token has been revoked"
                )

            return payload

        except jwt.ExpiredSignatureError:
            logger.warning("Token has expired")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.JWTError as e:
            logger.error(f"JWT error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )

    def refresh_access_token(self, refresh_token: str, device_id: Optional[str] = None) -> str:
        """
        使用刷新令牌获取新的访问令牌

        Args:
            refresh_token: 刷新令牌
            device_id: 设备ID

        Returns:
            新的访问令牌
        """
        # 验证刷新令牌
        payload = self.verify_token(refresh_token, "refresh")

        # 检查设备ID是否匹配
        if device_id and payload.get("device_id") != device_id:
            logger.warning(f"Device ID mismatch for user {payload.get('user_id')}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Device verification failed"
            )

        # 提取用户信息
        user_data = {
            "user_id": payload.get("user_id"),
            "username": payload.get("username"),
            "roles": payload.get("roles", []),
            "permissions": payload.get("permissions", [])
        }

        # 创建新的访问令牌
        new_access_token = self.create_access_token(
            user_data,
            device_id=device_id
        )

        logger.info(f"Refreshed access token for user {payload.get('user_id')}")
        return new_access_token

    def revoke_token(self, token_jti: str) -> None:
        """
        撤销令牌（加入黑名单）

        Args:
            token_jti: JWT ID
        """
        if not self.redis_client:
            logger.warning("Redis client not available, cannot revoke token")
            return

        # 添加到黑名单
        key = f"{self.blacklist_prefix}{token_jti}"
        # 设置过期时间为7天
        self.redis_client.setex(key, 7 * 24 * 3600, "revoked")

        # 从活跃token中删除
        active_key = f"jwt:active:{token_jti}"
        self.redis_client.delete(active_key)

        logger.info(f"Revoked token {token_jti}")

    def revoke_all_user_tokens(self, user_id: str) -> None:
        """
        撤销用户的所有令牌

        Args:
            user_id: 用户ID
        """
        if not self.redis_client:
            logger.warning("Redis client not available")
            return

        # 查找用户的所有活跃token
        pattern = "jwt:active:*"
        for key in self.redis_client.scan_iter(match=pattern):
            try:
                token = self.redis_client.get(key)
                if token:
                    payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
                    if payload.get("user_id") == user_id:
                        self.revoke_token(payload.get("jti"))
            except:
                continue

        logger.info(f"Revoked all tokens for user {user_id}")

    def is_token_blacklisted(self, token_jti: str) -> bool:
        """
        检查令牌是否在黑名单中

        Args:
            token_jti: JWT ID

        Returns:
            是否在黑名单中
        """
        if not self.redis_client:
            return False

        key = f"{self.blacklist_prefix}{token_jti}"
        return self.redis_client.exists(key) > 0

    def get_active_tokens_count(self, user_id: str) -> int:
        """
        获取用户的活跃令牌数量

        Args:
            user_id: 用户ID

        Returns:
            活跃令牌数量
        """
        if not self.redis_client:
            return 0

        count = 0
        pattern = "jwt:active:*"
        for key in self.redis_client.scan_iter(match=pattern):
            try:
                token = self.redis_client.get(key)
                if token:
                    payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
                    if payload.get("user_id") == user_id:
                        count += 1
            except:
                continue

        return count


def require_auth jwt_handler: JWTHandler):
    """
    JWT认证装饰器

    Args:
        jwt_handler: JWT处理器实例

    Returns:
        装饰器函数
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(request: Request, *args, **kwargs):
            # 从请求头获取token
            authorization = request.headers.get("Authorization")
            if not authorization:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authorization header missing"
                )

            try:
                scheme, token = authorization.split()
                if scheme.lower() != "bearer":
                    raise ValueError()
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid authorization header format"
                )

            # 验证token
            payload = jwt_handler.verify_token(token)

            # 获取设备指纹
            device_id = request.headers.get("X-Device-ID")
            if device_id and payload.get("device_id") != device_id:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Device verification failed"
                )

            # 将用户信息添加到请求状态
            request.state.user = payload

            return await func(request, *args, **kwargs)
        return wrapper
    return decorator


def require_permission(permission: str):
    """
    权限验证装饰器

    Args:
        permission: 需要的权限

    Returns:
        装饰器函数
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(request: Request, *args, **kwargs):
            user = getattr(request.state, "user", None)
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication required"
                )

            permissions = user.get("permissions", [])
            if permission not in permissions and "*" not in permissions:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Permission '{permission}' required"
                )

            return await func(request, *args, **kwargs)
        return wrapper
    return decorator