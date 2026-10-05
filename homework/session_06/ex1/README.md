# BÁO CÁO BÀI 1: KHẢO SÁT FHS VÀ PHÂN QUYỀN FILE/FOLDER NÂNG CAO

**Họ và tên học viên:** Nguyễn Phúc  
**Email:** phuchb24@gmail.com  
**Đường dẫn nộp bài trên GitHub:** `homework/session_06/ex1/`  
**Ngày thực hiện:** 05/10/2026  

---

## 1. Mục tiêu bài thực hành

- **Hiểu rõ Linux FHS (Filesystem Hierarchy Standard):** Nắm rõ vị trí và vai trò của thư mục `/var/www` trong việc lưu trữ dữ liệu ứng dụng web tĩnh và động.
- **Thành thạo kỹ năng quản lý thư mục:** Sử dụng các lệnh Linux (`mkdir`, `cd`, `ls`) để tạo và điều hướng cây thư mục hệ thống.
- **Phân quyền File/Folder nâng cao:** Làm chủ cơ chế phân quyền dạng số Octal (`chmod 750`, `chmod 770`) và dạng ký tự Symbolic.
- **Quản lý Quyền sở hữu (Ownership):** Thay đổi Chủ sở hữu (User Owner) và Nhóm sở hữu (Group Owner) bằng lệnh `chown` phù hợp với mô hình bảo mật máy chủ Web (Nginx / Apache / `www-data`).

---

## 2. Bối cảnh & Yêu cầu bài toán

Triển khai một thư mục chứa ứng dụng web dùng chung tại đường dẫn `/var/www/my-app` với cấu trúc và chính sách truy cập như sau:

```
/var/www/my-app/
├── public/    <-- Thư mục trang tĩnh công khai (dành cho Web Server đọc)
└── logs/      <-- Thư mục nhật ký hệ thống bảo mật (dành cho Web Server & Admin ghi log)
```

### Ràng buộc phân quyền bảo mật:

| Thư mục | Đường dẫn tuyệt đối | Chủ sở hữu (Owner) | Nhóm sở hữu (Group) | Người dùng khác (Others) | Octal Code | Permission String |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **`public`** | `/var/www/my-app/public` | Read, Write, Execute (`rwx`) | Read, Execute (`r-x`) | No access (`---`) | `750` | `drwxr-x---` |
| **`logs`** | `/var/www/my-app/logs` | Read, Write, Execute (`rwx`) | Read, Write, Execute (`rwx`) | No access (`---`) | `770` | `drwxrwx---` |

*Chủ sở hữu là một tài khoản non-root bình thường (ví dụ: `phuc`), và nhóm sở hữu là nhóm dịch vụ web mặc định (`www-data`).*

---

## 3. Kiến thức nền tảng (Theoretical Background)

### 3.1 Linux FHS & Thư mục `/var/www`
- **FHS (Filesystem Hierarchy Standard):** Định nghĩa chuẩn vị trí lưu trữ tệp tin trong hệ điều hành Linux.
- **Thư mục `/var` (Variable data):** Chứa các tệp tin có kích thước hoặc nội dung thay đổi liên tục trong quá trình hệ thống vận hành (logs, databases, cache).
- **Thư mục `/var/www`:** Chuẩn FHS dùng làm thư mục gốc chứa mã nguồn và dữ liệu dịch vụ máy chủ Web.

### 3.2 Cơ chế phân quyền trong Linux
Mỗi tệp tin/thư mục trong Linux có 3 cấp độ đối tượng truy cập:
1. **User (u):** Chủ sở hữu tệp tin.
2. **Group (g):** Các thành viên thuộc nhóm sở hữu tệp tin.
3. **Others (o):** Tất cả người dùng còn lại trên hệ thống.

Và 3 quyền hạn cơ bản:
- **Read (r - Bit value 4):** Đọc nội dung tệp / Liệt kê danh sách tệp trong thư mục.
- **Write (w - Bit value 2):** Chỉnh sửa nội dung tệp / Tạo, xóa tệp trong thư mục.
- **Execute (x - Bit value 1):** Chạy tệp kịch bản / Cho phép chuyển đến (`cd`) và truy cập vào bên trong thư mục.

#### Công thức tính Octal Code:
$$\text{Permission Code} = (\text{Read} \times 4) + (\text{Write} \times 2) + (\text{Execute} \times 1)$$

- `7` = $4 + 2 + 1 = \text{rwx}$ (Toàn quyền)
- `5` = $4 + 0 + 1 = \text{r-x}$ (Quyền đọc và điều hướng)
- `0` = $0 + 0 + 0 = \text{---}$ (Không có quyền)

---

## 4. Nhật ký thực thi chi tiết (Step-by-Step Execution Log)

### Bước 1: Khởi tạo cấu trúc thư mục FHS
Sử dụng `sudo` kết hợp tham số `-p` để tạo thư mục cha và thư mục con đồng thời nếu chưa tồn tại:

```bash
# Tạo thư mục web tĩnh (public) và thư mục nhật ký (logs)
sudo mkdir -p /var/www/my-app/public
sudo mkdir -p /var/www/my-app/logs
```

### Bước 2: Thiết lập Chủ sở hữu (User Owner) và Nhóm sở hữu (Group Owner)
Chuyển đổi quyền sở hữu `/var/www/my-app` và toàn bộ nội dung bên trong sang tài khoản non-root hiện tại (`$USER`) và nhóm máy chủ web (`www-data`):

```bash
# Đổi Owner thành user hiện tại ($USER = phuc) và Group thành www-data
sudo chown -R $USER:www-data /var/www/my-app
```

*Lưu ý:* Nếu hệ thống chưa có group `www-data`, có thể khởi tạo nhanh bằng lệnh: `sudo groupadd www-data`.

### Bước 3: Gán quyền truy cập dạng số Octal (Chmod)

#### 3.1 Cấu hình thư mục `public` (Quyền 750)
- Owner ($7 = rwx$): Đọc, ghi và điều hướng.
- Group ($5 = r-x$): Web server (`www-data`) có quyền đọc trang tĩnh và truy cập vào thư mục để phục vụ request HTTP.
- Others ($0 = ---$): Loại bỏ toàn bộ quyền truy cập của người dùng khác trên hệ thống.

```bash
sudo chmod 750 /var/www/my-app/public
```

#### 3.2 Cấu hình thư mục `logs` (Quyền 770)
- Owner ($7 = rwx$): Đọc, ghi và tạo/xóa tệp log.
- Group ($7 = rwx$): Web server (`www-data`) hoặc dịch vụ ghi log có toàn quyền ghi file nhật ký ứng dụng.
- Others ($0 = ---$): Tuyệt đối không cho phép người dùng khác đọc/xem log bảo mật.

```bash
sudo chmod 770 /var/www/my-app/logs
```

---

## 5. Kiểm tra kết quả thực hiện (Verification & Evidence)

Thực thi lệnh kiểm tra chi tiết danh sách tệp/thư mục:

```bash
ls -la /var/www/my-app
```

### Kết quả xuất ra màn hình Terminal (Actual Output):

```text
total 16
drwxr-xr-x 4 phuc www-data 4096 Oct  5 21:55 .
drwxr-xr-x 3 root root     4096 Oct  5 21:55 ..
drwxrwx--- 2 phuc www-data 4096 Oct  5 21:55 logs
drwxr-x--- 2 phuc www-data 4096 Oct  5 21:55 public
```

### Đánh giá kết quả kiểm tra:

1. **Thư mục `/var/www/my-app/public`:**
   - Quyền hiển thị: `drwxr-x---`
   - Giải thích: `d` (directory) | `rwx` (Owner = 7) | `r-x` (Group = 5) | `---` (Others = 0)
   - Kết quả: **ĐẠT [OK]** (Đúng chuẩn 750).

2. **Thư mục `/var/www/my-app/logs`:**
   - Quyền hiển thị: `drwxrwx---`
   - Giải thích: `d` (directory) | `rwx` (Owner = 7) | `rwx` (Group = 7) | `---` (Others = 0)
   - Kết quả: **ĐẠT [OK]** (Đúng chuẩn 770).

3. **Chủ sở hữu & Nhóm sở hữu:**
   - Owner: `phuc` (Tài khoản non-root bình thường)
   - Group: `www-data` (Nhóm quản lý dịch vụ Web)
   - Kết quả: **ĐẠT [OK]**.

---

## 6. Ma trận phân quyền tổng hợp (Permission Matrix)

| Đường dẫn Thư mục | Quyền Ký tự (Symbolic) | Quyền Số (Octal) | Chủ sở hữu (Owner) | Nhóm sở hữu (Group) | Mục đích Bảo mật |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `/var/www/my-app` | `drwxr-xr-x` | `755` | `phuc` | `www-data` | Thư mục gốc ứng dụng |
| `/var/www/my-app/public` | `drwxr-x---` | `750` | `phuc` | `www-data` | Phục vụ trang tĩnh, chặn người dùng thường |
| `/var/www/my-app/logs` | `drwxrwx---` | `770` | `phuc` | `www-data` | Ghi log bảo mật, cho phép Web server ghi |

---

## 7. Script Tự động hoá (Automation Setup Script)

Dự án đính kèm tệp kịch bản `setup.sh` hỗ trợ thiết lập tự động môi trường thực hành chỉ bằng 1 lệnh duy nhất:

```bash
chmod +x setup.sh
./setup.sh
```

---

## 8. Bài học kinh nghiệm & Nguyên tắc bảo mật (Security Best Practices)

1. **Nguyên tắc Đặc quyền Tối thiểu (Principle of Least Privilege - PoLP):**
   - Không cấp quyền `777` cho bất kỳ thư mục nào trên sản phẩm (production).
   - Thư mục `public` chỉ cần quyền Đọc & Điều hướng (`r-x`) đối với Web Server (`www-data`), không cho phép Web Server tự ý sửa đổi tệp tĩnh tại thư mục này nhằm tránh nguy cơ chèn mã độc (RCE/Web shell).

2. **Bảo mật Nhật ký Hệ thống (Log Security):**
   - Thư mục `logs` phải được khóa quyền `Others = 0` (`drwxrwx---` hoặc `770`) để ngăn chặn việc lộ thông tin nhạy cảm (như Token, IP, Credential) ra các người dùng local khác trên hệ thống shared server.

3. **Tách biệt đặc quyền Nginx/Apache:**
   - Máy chủ Web chạy dưới user/group hạn chế (`www-data` hoặc `nginx`), còn mã nguồn được sở hữu bởi user deploy/developer (`phuc`), ngăn chặn triệt để nguy cơ chiếm đoạt quyền root khi ứng dụng bị khai thác lỗ hổng.
