# Dọn repository trước khi nộp

Đã thực hiện ngày 21/10/2026 theo yêu cầu của người dùng, trên nhánh `main-test` sau a153046. Người dùng đã yêu cầu commit/push báo cáo, dự án và phần dọn repo bằng tên Git của mình. Báo cáo, ảnh và kịch bản từ các lượt trước được đưa vào cùng phạm vi xuất bản; thông tin hỗ trợ AI vẫn được giữ minh bạch.

Lượt xuất bản bổ sung gom 35 bản sao evidence giống hệt nội dung, tiết kiệm 210,385 bytes; mọi tên cũ được ánh xạ tới file gốc giữ lại tại [aliases.json](evidence/aliases.json), với SHA-256 và kích thước. Đây là bước sau kiểm tra bảo toàn 673 file ở lượt trước. [Kiểm tra xuất bản](evidence/publication-20261021/README.md) xác minh lại toàn bộ payload gốc qua bảng ánh xạ.

## Nên loại khỏi Git và thêm ignore nếu bị đưa vào

**Đã hoàn tất.** Kiểm tra danh sách tracked không tìm thấy file cache, service state, SDK-local properties, database riêng hoặc binary release thuộc nhóm đề xuất. Vì vậy không có source nào trong nhóm này cần gỡ khỏi index; các file phát sinh trên máy được giữ để tiếp tục chạy dự án.

| File/thư mục | Đã xử lý |
| --- | --- |
| `outputs/taskflow-running-services.json` | Thêm ignore chính xác; file cục bộ không còn xuất hiện trong `git status` |
| `build-apk.log`, `android-build-host.*.log` | Đã được `*.log` bỏ qua; bổ sung ngoại lệ cho log gốc trong `docs/evidence/` và `docs/report/evidence/` |
| `build/`, `.dart_tool/`, `.flutter-plugins-dependencies`, `coverage/` | Giữ ignore đã có; không xóa cache hoặc công cụ render trên máy |
| `android/local.properties` | Giữ ignore ở Android và khai báo rõ tại root; không đưa đường dẫn SDK riêng vào Git |
| `backend/data/`, `backend/backups/`, `.env`, database SQLite của backend | Giữ ignore hiện có; bảo vệ `.env.example` để tái tạo cấu hình |
| `backend/node_modules/`, `node_modules/` | Giữ ignore backend, thêm ignore dependency cục bộ ở root |
| `tmp/`, `temp/`, `output/qa/`, `output/previews/` | Giữ ignore cho sản phẩm trung gian |
| IDE state, `__pycache__/`, file khóa `~$*.docx` | Giữ ignore hiện có |

Không sửa lịch sử Git hoặc thu hồi credential trong lượt này. Các phép kiểm tra trên xác nhận quy tắc đường dẫn và trạng thái tracked, không phải chứng nhận đã quét mọi secret trong toàn bộ lịch sử.

## Có thể gọn lại sau khi nhóm duyệt

**Đã hoàn tất theo yêu cầu triển khai hiện tại.** Word và PDF xuất từ Word là cặp báo cáo chính; nguồn LaTeX vẫn được giữ.

| Mục | Kết quả |
| --- | --- |
| Prompt triển khai ở root | Chuyển sang [docs/process/PROJECT_IMPLEMENTATION_PROMPT.md](process/PROJECT_IMPLEMENTATION_PROMPT.md); sửa tham chiếu trong AGENTS, README và roadmap; thêm hướng dẫn tại [docs/process/README.md](process/README.md) |
| PDF LaTeX cũ | Xóa `output/pdf/taskflow-report.pdf` khỏi bản làm việc, bỏ liên kết nộp bài tới file này và thêm ignore để bản biên dịch tùy chọn không bị commit lại |
| Log chuẩn bị báo cáo cũ | Thêm [phân loại historical và nguồn gốc](report/evidence/README.md) tại đường dẫn đang được báo cáo tham chiếu; giữ nguyên năm file log/probe |
| Audit và ghi chép theo ngày | Thêm [mục lục 16 ghi chép](history/README.md), liên kết từ README và evidence manifest; giữ vị trí gốc để không làm hỏng trích dẫn |

PDF cũ có bản sao cục bộ tại `build/repo-cleanup-20261021/taskflow-report-latex-historical.pdf`, thuộc thư mục đã ignore. Bản sao có 456,477 bytes, SHA-256 `6caea44d873c1b05de4455f32bf0fdc282e3f35fffeb3553d05aa7f14dc5a2f4`. Việc xóa ở bản làm việc sẽ được GitHub phản ánh khi commit/push được duyệt; phiên bản cũ vẫn có trong lịch sử Git.

## Kiểm tra đã thực hiện

- 21 đường dẫn mẫu của file tạm, dependency, dữ liệu riêng và PDF LaTeX tùy chọn được ignore đúng.
- 9 đường dẫn cần giữ, gồm log evidence mới, `.env.example`, lockfiles, báo cáo chính và golden baseline, không bị ignore.
- 38 liên kết trong ba index mới trỏ tới file tồn tại.
- 673 file bằng chứng trước lượt dọn giữ nguyên SHA-256; chỉ `docs/evidence/manifest.md` được thêm mục điều hướng. README phân loại historical là file mới.
- `git diff --check` PASS. Không đổi mã ứng dụng hoặc test; không chạy lại Flutter/API suite cho thay đổi tài liệu và ignore.

Kết quả kiểm tra cục bộ: `build/repo-cleanup-20261021/validation.json` (ignored).

## Nên giữ

- `pubspec.lock`, `backend/package-lock.json`, platform scaffold, build/test scripts và CI workflow.
- `AGENTS.md`, `.metadata`, `.gitattributes`, cấu hình mẫu và tài liệu tái tạo.
- Golden baselines, report assets, font licences, nguồn báo cáo và cặp Word/PDF matching.
- Toàn bộ log FAIL/PASS gốc và intentional-defect package; không xóa log theo đuôi file.
- Manual-test script, kịch bản demo và hồ sơ đóng góp đã được nhóm xác nhận.

APK/ZIP release nên phân phối qua GitHub Releases hoặc artifact CI có checksum. Chưa tạo release hoặc upload binary.

## Phạm vi commit sau khi duyệt

Bao gồm cập nhật báo cáo/ảnh/kịch bản từ các lượt trước, sửa LaTeX và thay đổi dọn repo. Prompt được chuyển vị trí và PDF LaTeX cũ được loại khỏi bộ nộp; service state vẫn ở máy và được ignore. Identity được xác minh là `Long-D176 <523k0014@student.tdtu.edu.vn>`. Giữ nguyên cả hai đồng tác giả trong báo cáo. Xem commit thực tế bằng `git log -1` và trạng thái nhánh remote sau push.
