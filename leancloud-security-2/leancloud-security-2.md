<!-- $theme: gaia -->

# LeanCloud 与数据安全（二）

#### asaka @ LeanCloud

-----

## Simple CLI Forum

- User
- Post

-----

## User

不能获取查询全部用户：
- Class 权限，不允许 find（默认行为）

不能修改／删除用户信息：
- Object 权限，只允许当前用户操作（默认行为）

不能查看用户隐私数据：
- 通过设置 `_User` 对应字段属性实现

-----

## Post

只允许登录用户可以发帖:
- Class 权限，只允许登录用户拥有 create 权限

只允许作者／管理员修改／删除帖子：
- Object 权限，只允许作者／管理员进行相关操作

-----

## Post

不允许黑名单用户发贴
- 通过云函数 `beforeSave` 进行过滤

不允许查看已经标记隐藏的帖子：
- 云引擎提供云函数，进行查询
