// ES5代码示例 - 用于演示ES5到ES6的转换
// 使用提示词：claude "将这个ES5文件转换为现代ES6+语法"

// Old ES5 code
function UserService() {
  this.users = [];
  var self = this;

  this.fetchUsers = function(callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/users', true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          self.users = JSON.parse(xhr.responseText);
          callback(null, self.users);
        } else {
          callback(new Error('Failed to fetch users'));
        }
      }
    };
    xhr.send();
  };

  this.getUserById = function(id, callback) {
    var user = null;
    for (var i = 0; i < this.users.length; i++) {
      if (this.users[i].id === id) {
        user = this.users[i];
        break;
      }
    }
    callback(null, user);
  };

  this.filterActiveUsers = function() {
    var activeUsers = [];
    for (var i = 0; i < this.users.length; i++) {
      if (this.users[i].isActive) {
        activeUsers.push(this.users[i]);
      }
    }
    return activeUsers;
  };
}

// Prototype methods
UserService.prototype.addUser = function(user) {
  var self = this;
  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/api/users', true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 201) {
        var newUser = JSON.parse(xhr.responseText);
        self.users.push(newUser);
      }
    }
  };
  xhr.send(JSON.stringify(user));
};

// Usage example
var service = new UserService();
service.fetchUsers(function(err, users) {
  if (err) {
    console.error('Error:', err.message);
    return;
  }

  console.log('Users loaded:', users.length);
  var activeUsers = service.filterActiveUsers();
  console.log('Active users:', activeUsers.length);
});

// Export
module.exports = UserService;