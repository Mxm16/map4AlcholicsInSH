# 酒鬼地图暖心版

自动请求定位，显示上海酒鬼巡游记26五期最近5家，按直线距离排序。91条名单采集于2026-11-09；部分坐标按楼栋估算。手机首次使用需允许定位。

## 发布到 GitHub Pages

1. 在 GitHub 创建一个公开仓库，例如 `jiugui-map`。
2. 将本目录中的 `index.html` 和 `.nojekyll` 上传到仓库根目录并提交。
3. 在仓库 **Settings → Pages → Build and deployment**，选择 **Deploy from a branch**。
4. Branch 选择 `main`，目录选择 `/ (root)`，保存。
5. 等待 GitHub 显示正式的 HTTPS 链接，再发到微信打开。

这是纯静态版本，不含地图 Key，也不请求原站服务器。自动定位与排序可独立工作。定位失败时可以从名单选择附近酒馆作为参考出发点，或者输入高德坐标；此版本不提供任意地址地理编码。

GitHub Pages 国内网络可达性与微信定位兼容性需手机实测。
