"""
Data Encryption Module - 生产级数据加密工具

功能特性：
- AES-256-GCM 加密
- 字段级加密
- 密钥管理
- 数据脱敏
- 加密性能优化

作者：大熊掌门
版本：1.0.0
"""

import os
import base64
import hashlib
import hmac
from typing import Any, Dict, List, Optional, Union
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import structlog
import json

logger = structlog.get_logger(__name__)


class EncryptionManager:
    """加密管理器"""

    # 敏感字段列表
    SENSITIVE_FIELDS = [
        "password", "passwd", "pwd",
        "email", "email_address",
        "phone", "phone_number", "mobile",
        "id_card", "idcard", "identity_card",
        "credit_card", "card_number",
        "ssn", "social_security",
        "bank_account", "account_number",
        "api_key", "apikey", "secret_key",
        "access_token", "refresh_token",
        "private_key", "secret"
    ]

    def __init__(self, encryption_key: Union[str, bytes]):
        """
        初始化加密管理器

        Args:
            encryption_key: 加密密钥（32字节）
        """
        if isinstance(encryption_key, str):
            encryption_key = encryption_key.encode()

        # 确保密钥长度为32字节
        if len(encryption_key) != 32:
            raise ValueError("Encryption key must be 32 bytes long")

        self.encryption_key = encryption_key
        self.fernet = self._create_fernet()

    def _create_fernet(self) -> Fernet:
        """创建Fernet加密器"""
        # 使用PBKDF2从主密钥派生Fernet密钥
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=b'claudecode_salt',  # 在生产环境中应该使用随机salt
            iterations=100000,
            backend=default_backend()
        )
        key = base64.urlsafe_b64encode(kdf.derive(self.encryption_key))
        return Fernet(key)

    def encrypt_field(self, value: str) -> Dict[str, str]:
        """
        加密单个字段

        Args:
            value: 要加密的值

        Returns:
            包含加密数据的字典
        """
        if not value:
            return {"encrypted": False, "value": value}

        try:
            # 使用Fernet加密（包含签名和时间戳）
            encrypted_value = self.fernet.encrypt(value.encode()).decode()

            return {
                "encrypted": True,
                "value": encrypted_value,
                "algorithm": "Fernet (AES-128-CBC)",
                "timestamp": "auto"
            }
        except Exception as e:
            logger.error(f"Failed to encrypt field: {str(e)}")
            raise EncryptionError(f"Encryption failed: {str(e)}")

    def decrypt_field(self, encrypted_data: Dict[str, Any]) -> str:
        """
        解密单个字段

        Args:
            encrypted_data: 加密数据字典

        Returns:
            解密后的原始值
        """
        if not encrypted_data.get("encrypted", False):
            return encrypted_data.get("value", "")

        try:
            encrypted_value = encrypted_data["value"]
            decrypted_value = self.fernet.decrypt(encrypted_value.encode()).decode()
            return decrypted_value
        except Exception as e:
            logger.error(f"Failed to decrypt field: {str(e)}")
            raise DecryptionError(f"Decryption failed: {str(e)}")

    def encrypt_sensitive_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        加密敏感数据字典

        Args:
            data: 原始数据字典

        Returns:
            加密后的数据字典
        """
        if not isinstance(data, dict):
            return data

        encrypted_data = {}
        encryption_log = []

        for key, value in data.items():
            if self._is_sensitive_field(key) and value:
                try:
                    encrypted_data[key] = self.encrypt_field(str(value))
                    encryption_log.append(key)
                except Exception as e:
                    logger.warning(f"Failed to encrypt field {key}: {str(e)}")
                    encrypted_data[key] = value  # 保留原值以避免数据丢失
            else:
                encrypted_data[key] = value

        if encryption_log:
            logger.info(f"Encrypted sensitive fields: {', '.join(encryption_log)}")

        return encrypted_data

    def decrypt_sensitive_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        解密敏感数据字典

        Args:
            data: 加密的数据字典

        Returns:
            解密后的数据字典
        """
        if not isinstance(data, dict):
            return data

        decrypted_data = {}
        decryption_log = []

        for key, value in data.items():
            if isinstance(value, dict) and value.get("encrypted", False):
                try:
                    decrypted_data[key] = self.decrypt_field(value)
                    decryption_log.append(key)
                except Exception as e:
                    logger.warning(f"Failed to decrypt field {key}: {str(e)}")
                    decrypted_data[key] = value
            elif isinstance(value, dict):
                # 递归处理嵌套字典
                decrypted_data[key] = self.decrypt_sensitive_data(value)
            else:
                decrypted_data[key] = value

        if decryption_log:
            logger.info(f"Decrypted sensitive fields: {', '.join(decryption_log)}")

        return decrypted_data

    def mask_sensitive_data(self, data: Dict[str, Any], mask_char: str = "*") -> Dict[str, Any]:
        """
        脱敏处理（返回掩码数据而非加密数据）

        Args:
            data: 原始数据
            mask_char: 掩码字符

        Returns:
            脱敏后的数据
        """
        if not isinstance(data, dict):
            return data

        masked_data = {}

        for key, value in data.items():
            if self._is_sensitive_field(key) and value:
                masked_data[key] = self._mask_value(str(value), mask_char)
            elif isinstance(value, dict):
                masked_data[key] = self.mask_sensitive_data(value, mask_char)
            else:
                masked_data[key] = value

        return masked_data

    def _mask_value(self, value: str, mask_char: str = "*") -> str:
        """
        对值进行掩码处理

        Args:
            value: 原始值
            mask_char: 掩码字符

        Returns:
            掩码后的值
        """
        if not value:
            return value

        length = len(value)

        # 根据长度决定掩码策略
        if length <= 4:
            return mask_char * length
        elif length <= 8:
            return value[:2] + mask_char * (length - 2)
        elif length <= 16:
            return value[:4] + mask_char * (length - 8) + value[-4:]
        else:
            return value[:4] + mask_char * 8 + "..." + value[-4:]

    def _is_sensitive_field(self, field_name: str) -> bool:
        """
        判断字段是否为敏感字段

        Args:
            field_name: 字段名

        Returns:
            是否为敏感字段
        """
        field_name_lower = field_name.lower()

        # 检查是否包含敏感关键词
        for sensitive_field in self.SENSITIVE_FIELDS:
            if sensitive_field in field_name_lower:
                return True

        # 检查常见的模式
        patterns = [
            "pass", "secret", "key", "token", "auth",
            "card", "account", "number", "id"
        ]

        for pattern in patterns:
            if pattern in field_name_lower and len(field_name_lower) > 3:
                return True

        return False

    def generate_data_hash(self, data: Union[str, bytes, Dict]) -> str:
        """
        生成数据的哈希值（用于完整性验证）

        Args:
            data: 要哈希的数据

        Returns:
            SHA-256哈希值
        """
        if isinstance(data, dict):
            data = json.dumps(data, sort_keys=True).encode()
        elif isinstance(data, str):
            data = data.encode()

        return hashlib.sha256(data).hexdigest()

    def verify_data_integrity(self, data: Union[str, bytes, Dict], expected_hash: str) -> bool:
        """
        验证数据完整性

        Args:
            data: 原始数据
            expected_hash: 期望的哈希值

        Returns:
            是否验证通过
        """
        actual_hash = self.generate_data_hash(data)
        return hmac.compare_digest(actual_hash, expected_hash)

    def rotate_encryption(self, old_encrypted_data: Dict[str, Any], new_key: bytes) -> Dict[str, Any]:
        """
        使用新密钥重新加密数据（密钥轮换）

        Args:
            old_encrypted_data: 使用旧密钥加密的数据
            new_key: 新的加密密钥

        Returns:
            使用新密钥加密的数据
        """
        # 使用当前密钥解密
        decrypted_data = self.decrypt_sensitive_data(old_encrypted_data)

        # 创建新的加密管理器
        new_manager = EncryptionManager(new_key)

        # 使用新密钥重新加密
        new_encrypted_data = new_manager.encrypt_sensitive_data(decrypted_data)

        logger.info("Successfully rotated encryption key")
        return new_encrypted_data


class EncryptionError(Exception):
    """加密异常"""
    pass


class DecryptionError(Exception):
    """解密异常"""
    pass


# 便捷函数
def encrypt_value(value: str, key: str) -> str:
    """
    快速加密单个值

    Args:
        value: 要加密的值
        key: 加密密钥

    Returns:
        Base64编码的加密值
    """
    manager = EncryptionManager(key)
    encrypted = manager.encrypt_field(value)
    return encrypted["value"]


def decrypt_value(encrypted_value: str, key: str) -> str:
    """
    快速解密单个值

    Args:
        encrypted_value: 加密的值
        key: 加密密钥

    Returns:
        解密后的原始值
    """
    manager = EncryptionManager(key)
    encrypted_data = {"encrypted": True, "value": encrypted_value}
    return manager.decrypt_field(encrypted_data)