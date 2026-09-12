# Kế hoạch nâng cấp TaskFlow QA Lab trong phạm vi giữa kỳ

Ngày lập: 12/09/2026. Trạng thái: **đề xuất để nhóm duyệt, chưa triển khai**.
Tài liệu do agent hỗ trợ soạn; nhóm cần xem xét, hiểu và điều chỉnh theo thời gian
thực tế. Không phải báo cáo học thuật cuối và không cam kết điểm số.

## 1. Mục tiêu và cách hiểu phạm vi

Đề tài 4: **UI Automation Testing in Flutter: Implementing End-to-End Testing**.
Nâng cấp app để tạo tình huống kiểm thử sâu hơn, trải nghiệm rõ ràng hơn và bằng
chứng dễ tái tạo hơn; không chạy theo số lượng tính năng hoặc số lượng test.

Định hướng: một ứng dụng quản lý công việc cá nhân nhỏ, có chế độ offline,
sandbox và tài khoản riêng biệt. Không chuyển thành nền tảng cộng tác hay SaaS.

Mỗi đề xuất phải trả lời được:

1. Người dùng đang gặp bất tiện/rủi ro cụ thể nào?
2. Có thể kiểm chứng thay đổi ở tầng test nào, vì sao chọn tầng đó?
3. Có bằng chứng trước/sau hoặc tiêu chí chấp nhận quan sát được không?
4. Có thể hoàn thành và giải thích trong một buổi demo ngắn không?

Nếu chỉ có lợi ích trang trí, hoặc không kiểm thử được trong điều kiện nhóm,
đưa vào danh sách tùy chọn, không đặt trên các hạng mục bảo toàn dữ liệu.

## 2. Điểm xuất phát đã biết

- Source nền: commit `0753db1`, branch `main-test`.
- 72 test Flutter, gồm 11 golden; 14 test backend; 10 ca Windows đã có log PASS.
- Đã có UI Color Studio, metadata, tìm kiếm/lọc/sắp xếp, CRUD/undo, dữ liệu mẫu
  tách biệt, backend tài khoản/SQLite, kiểm soát revision và lỗi tải/lưu.
- Đã có thí nghiệm search defect ở tầng widget, đo lặp các tầng test, Edge QA.
- Ba lỗi mới nhất đã được sửa: ghi đè snapshot chưa tải, logout cũ xóa phiên mới,
  sai mật khẩu sau refresh gây logout. Không được bỏ các test hồi quy này.
- Các kết quả này là mốc nền, không tự động chứng minh mọi nâng cấp sau đều PASS.
- CI của bản mới phải kiểm tra lại theo commit; Android cũ không đại diện bản mới.
- Môi trường máy này chưa có Android SDK. Windows + Web là cặp kiểm chứng chính;
  Android là nhánh bổ sung khi toolchain/CI có sẵn, không tự ý cài đặt.

Nguồn đối chiếu: đề gốc `503107-Essay-V2 (1).pdf`, trang 3–4 (Topic 4),
5–7 (chiều sâu và chất lượng), 8–9 (đầu ra và điều kiện chấm); `AGENTS.md`,
`PROJECT_IMPLEMENTATION_PROMPT.md`, `docs/evidence/manifest.md`.
Windows + Web đáp ứng lựa chọn hai nền tảng với một nền tảng native khi có bằng
chứng phù hợp. Đề không bắt buộc backend, hosting công khai hoặc riêng Android.

## 3. Giới hạn cứng

### Không mở rộng trong kế hoạch này

- Chat, nhóm làm việc, chia sẻ task, role/permission đa tầng.
- Realtime/WebSocket, push notification, đồng bộ offline-online tự động.
- AI assistant, calendar tích hợp bên ngoài, thanh toán/subscription.
- SMTP, social login, MFA, triển khai cloud hoặc vận hành production.
- Microservice, thay framework state management, đổi toàn bộ database.
- Drag-and-drop Kanban, task lặp lịch, subtasks và lịch sử phiên bản tổng quát.
- Thêm nhiều framework E2E chỉ để có bảng so sánh; không bắt buộc cài Patrol,
  Appium và Maestro cùng lúc.
- Thiết kế lại toàn bộ UI lần nữa hoặc sửa SDK Flutter.

### Quy tắc bảo toàn

- Không upload offline data; không đọc/ghi đè tài khoản thật khi kiểm thử.
- Không xóa preference ngoài các key test; DB thử nghiệm phải riêng biệt.
- Không nâng version/package nếu chưa có lý do, kiểm tra tương thích và license.
- Không đổi golden chỉ để làm test PASS; cần xem actual/expected/diff.
- Không sửa log cũ để khớp source mới; luôn gắn kết quả với commit và môi trường.
- Không commit/push, publish artifact, cài SDK/tool nếu chưa có yêu cầu phù hợp.
- Viết kế hoạch không đồng nghĩa đã có quyền thực hiện mọi hạng mục bên dưới.

## 4. Danh mục ưu tiên và ngân sách

Ước lượng dưới đây là **ngày công tập trung**, không phải cam kết tiến độ;
phụ thuộc kinh nghiệm nhóm và lỗi môi trường. Chốt lịch sau khi biết hạn nộp.

| Gói | Ưu tiên | Nội dung | Ước lượng | Điều kiện |
|---|---|---|---:|---|
| A | P0 | Chuẩn hóa trạng thái, bằng chứng và cổng chất lượng | 0,5–1 | Làm trước mọi nâng cấp |
| B | P1 | Form an toàn, thao tác rõ ràng, giữ bản nháp | 1,5–2,5 | Không thay data model |
| C | P1 | Khôi phục sau lỗi/conflict tốt hơn | 1,5–2,5 | Dùng revision API hiện có |
| D | P1 | E2E độc lập và thí nghiệm lỗi ở tầng native | 1,5–2,5 | Sau B/C |
| E | P1 | Accessibility thực tế và bố cục biên | 1–2 | Cần người thực hiện phần thủ công |
| F | P1 | Bộ bàn giao chạy được, kiểm tra máy sạch | 1–2 | Sau khi đóng băng tính năng |
| G | P2 | Một cải tiến trải nghiệm tùy chọn | 0,5–1,5 | Chỉ chọn tối đa một |

Tổng lõi A–F khoảng 7–12,5 ngày công; không tính soạn báo cáo/video và thời gian
chờ SDK/CI. Không được lấy toàn bộ thời gian còn lại cho code: đề có 6 điểm báo
cáo và 4 điểm demo, cùng đầu ra bắt buộc. Dành riêng quỹ thời gian cho nhóm tự
kiểm chứng, báo cáo, video và vấn đáp; các việc này chưa được triển khai ở đây.

Nếu chỉ còn 3–5 ngày công: làm A, phần quan trọng nhất của B/C, E/F; bỏ G và
thí nghiệm bổ sung D nếu không đủ thời gian. Không cắt kiểm thử của phần đã sửa.

## 5. Gói A — Thiết lập một trạng thái hiện tại đáng tin cậy

Tiến độ 12/09/2026: đã tạo `current-verified-state.md`, đồng bộ các tài liệu
đầu vào và kiểm tra CI đúng SHA 0753db1. Không thêm runner mới vì chưa cần thiết.
Kết quả kiểm tra bổ sung ở `evidence/upgrade-a-20260912/` và manifest.
Các gói B–G bên dưới vẫn là kế hoạch, chưa được triển khai trong gói A.

### Công việc

- Rà `README`, `AGENTS`, traceability, test matrix, limitations và manifest.
- Tạo một phần “Current verified state” thống nhất; chuyển số liệu cũ vào lịch sử.
- Bỏ mô tả hiện tại kiểu “uncommitted” khi commit đã tồn tại, nhưng giữ ngữ cảnh
  log chụp trước commit. Ghi source commit tương ứng, không sửa raw output.
- Kiểm tra CI đúng SHA; phân biệt queued/running/failed/passed và artifact còn hạn.
- Ghi rõ lệnh test, SDK, nền tảng, loại storage, dataset và mức độ fidelity.
- Có thể thêm script quality-gate tổng hợp: ghi riêng stdout/stderr, exit code,
  thời gian; nonzero phải làm cả gate thất bại. Không che lỗi bằng lệnh cuối PASS.

### Tiêu chí hoàn thành

- Một yêu cầu bất kỳ truy được đến code → test → log → giới hạn bằng chứng.
- Tổng hợp chỉ đếm các ca thực thi, không cộng số vòng lặp thành test mới.
- Script nếu được thêm phải có contract test cho FAIL, lệnh thiếu và output trùng.

File chính: `docs/requirements-traceability.md`, `docs/test-matrix.md`,
`docs/evidence/manifest.md`, `README.md`, `AGENTS.md`, `scripts/`.

## 6. Gói B — Form và thao tác an toàn hơn

### B1. Bảo vệ bản nháp chưa lưu

- Khi đóng form Edit bằng Cancel/Escape/Back, chỉ xác nhận bỏ thay đổi nếu dữ liệu
  thực sự khác bản gốc. Form không đổi đóng ngay, không gây thêm bước thừa.
- Chọn “Continue editing” giữ nguyên mọi field và focus hợp lý; “Discard” không
  ghi repository. Trong khi đang lưu, giữ cơ chế ngăn đóng/submit lặp hiện có.
- Với quick-create, chỉ chặn rời workspace khi có bản nháp có ý nghĩa; không
  lưu password hoặc task draft vào preferences trong gói này.
- Không hứa bảo vệ bản nháp khi đóng tab/kill process: đó là phạm vi khác.

### B2. Validation nhất quán và dễ sửa lỗi

- Tách validation dùng chung ở domain khi có trùng lặp có rủi ro; không tái cấu
  trúc toàn bộ form. Test title/notes/tags/date ở biên và dữ liệu Unicode.
- Kiểm tra chi tiết bị thu gọn có làm bỏ qua field invalid hay không; nếu có,
  mở vùng lỗi và focus field đầu tiên thay vì lưu dữ liệu cũ âm thầm.
- Trạng thái không thể ghi phải có giải thích/Retry rõ; không để thao tác im lặng.
- Có thể thêm date picker bên cạnh nhập YYYY-MM-DD, giữ cách nhập bằng bàn phím.
  Đây là lựa chọn tiện ích, không cần thêm thư viện lịch.

### Kiểm thử và hoàn thành

- Unit: so sánh dirty state và validation boundaries.
- Widget: cancel sạch/bẩn, giữ/bỏ draft, Escape/Back, invalid trong vùng thu gọn,
  pending save, text scale 200%; repository spy chứng minh không ghi khi cancel.
- Native: một scenario edit → bỏ đóng → lưu → remount → dữ liệu đúng.
- Không mất notes/date/tags hoặc vô tình đổi completed khi chỉ sửa title.
- Chỉ cập nhật golden của trạng thái thực sự đổi và đã review.

File chính: `edit_task_dialog.dart`, `task_details_fields.dart`, `task_screen.dart`,
domain validation, `test/widget/`, `integration_test/`.

## 7. Gói C — Khôi phục lỗi và conflict có kiểm soát

### C1. Phân biệt lỗi theo hành động có ích

- Tách thông điệp network, unauthorized, conflict và dữ liệu không đọc được.
- Lỗi tải không được cho ghi snapshot chưa xác nhận; giữ guard đã sửa.
- Timeout save không được tự động gửi lại vì server có thể đã commit.
- Hiển thị hành động phù hợp: Reload, Retry load, Sign in again; không có nút
  hứa retry an toàn nếu thực chất ghi đè snapshot cũ.

### C2. Conflict khi đang sửa task

- Giữ bản nháp trong RAM và hiển thị rằng dữ liệu server đã thay đổi.
- Cho tải lại dữ liệu hiện tại, hiển thị bản server và bản nháp đủ rõ để người
  dùng chọn áp dụng lại thay đổi hoặc bỏ draft. Không tự merge field.
- Trước khi ghi lại phải có revision mới; nếu conflict lần nữa, tiếp tục báo lỗi.
- Nếu task đã bị xóa ở server, không tự tạo lại dưới cùng ID. Giải thích và cho
  bỏ draft; “tạo bản mới” chỉ làm nếu nhóm duyệt riêng, không mặc định triển khai.
- Sau logout/account switch, không mang draft riêng tư sang tài khoản khác.

### Kiểm thử và hoàn thành

- Mock HTTP: timeout sau commit, conflict, 401, response không hợp lệ.
- Native online với DB riêng: hai client cùng revision → client A lưu → client B
  conflict → reload → người dùng quyết định → dữ liệu cuối đúng.
- Unit/widget: không mất draft, không tự ghi lại, không rò sang account khác.
- Không thay giao thức REST, không xây conflict engine hoặc sync offline.

File chính: `api_client.dart`, `remote_task_repository.dart`, `task_controller.dart`,
Edit dialog và `integration_test/online_workflow_test.dart`.

## 8. Gói D — Làm sâu phần E2E, không chỉ tăng số test

### D1. Bản đồ rủi ro và độc lập test

- Mỗi luồng mới ở B/C phải có initial state, observable result và cleanup riêng.
- Chọn unit cho rule; widget cho rendering/interactions; native cho persistence
  hoặc API thực. Không copy mọi tổ hợp qua tất cả các tầng.
- Rà helper bounded wait/scroll; ghi điều kiện đang chờ khi timeout.
- Tách “remount widget”, “restart process”, “restart OS”; không gọi chúng là nhau.

### D2. Thí nghiệm lỗi cố ý ở native E2E — đề xuất tăng chiều sâu

Đề hiện đã có widget fail/fix đáp ứng yêu cầu; đây là nâng cấp, không phải thiếu
bắt buộc. Dùng cùng lỗi substring/prefix để so sánh khả năng phát hiện ở hai tầng.

1. Chọn native scenario có assertion exact task set/order và chứng minh baseline PASS.
2. Dùng checkout dùng một lần; patch chỉ đổi điều kiện search, không sửa test.
3. Chạy widget và native test riêng, giữ raw FAIL và exit code.
4. Khôi phục patch; chạy lại cùng test và full gate, giữ raw PASS.
5. Phân tích chi phí build/launch và loại lỗi phát hiện; không kết luận E2E luôn tốt hơn.

Không thực hiện trên checkout có thay đổi chưa bảo vệ; không commit source lỗi.

### D3. Thí nghiệm nhỏ, hữu ích

- Chọn một câu hỏi: ảnh hưởng cold/warm build hoặc fresh browser session đến thời gian.
- 3–5 lần mỗi điều kiện nếu đủ ngân sách; ghi workload tương đương, thứ tự chạy,
  phiên bản, cache, mean/median và toàn bộ fail/interruption.
- Không dùng số mẫu nhỏ để tuyên bố tỷ lệ ổn định cho mọi máy.
- Chuẩn bị nguyên liệu so sánh unit/widget/golden/E2E theo fidelity, tốc độ,
  maintenance và debugging; việc viết báo cáo cuối vẫn tách riêng.

## 9. Gói E — Accessibility và responsive thực tế

### Kiểm tra có thứ tự

1. Keyboard-only: Tab/Shift+Tab, Enter/Space, Escape, focus sau dialog/retry/delete.
2. Narrator: tiêu đề, label, error, loading, trạng thái checkbox và số lượng task.
3. Viewport 320/390, 768 và 1280 trở lên; text scale 100%/200%, dialog thấp màn hình.
4. Dữ liệu dài: title 120 ký tự, notes 2000, 10 tags; kiểm tra cuộn và không che CTA.
5. Hoàn thành/xóa không chỉ phân biệt bằng màu; giữ text và semantics rõ ràng.

### Nâng cấp theo lỗi quan sát được

- Sửa focus trap, tab order sai, label trùng, thông báo không được đọc hoặc overflow.
- Khôi phục focus về phần tử có ý nghĩa khi phần tử cũ bị xóa.
- Không giảm cỡ chữ để giấu overflow; ưu tiên wrap/scroll/layout phù hợp.
- Không tự thêm dark mode/motion trước khi giao diện hiện tại vượt qua protocol.

### Tiêu chí hoàn thành

- Có checklist ghi người thực hiện, OS/browser, thao tác, kết quả và vấn đề.
- Có regression widget cho lỗi có thể tự động hóa; clip/screenshot cho phần thủ công.
- Không tuyên bố “WCAG compliant” chỉ từ automated guidelines PASS.
- Nếu không có người/tool phù hợp chạy Narrator: giữ NOT RUN, không mô phỏng log.

## 10. Gói F — Tái tạo và bàn giao đáng tin cậy

- Chốt source SHA, SDK, lockfile và các lệnh chạy; không nâng SDK sát ngày nộp.
- Tạo gói Windows Release đầy đủ DLL/data/assets và checksum, không chỉ `.exe`.
- Để package/ZIP trong `build/` bị ignore. Chỉ đưa hướng dẫn, checksum và log đã
  duyệt vào source khi được phép commit; không đẩy binary lớn vào Git tùy tiện.
- Một thành viên khác làm README từ đầu trên máy sạch/khác; ghi từng chỗ phải sửa.
- Chạy offline/sandbox không cần backend; online chỉ rõ Node, port, DB riêng và
  startup/shutdown. Không phát hành tài khoản hoặc token thật trong gói demo.
- Demo Android nếu CI/toolchain sẵn có: xác nhận đúng SHA, cài/mở APK, chạy luồng
  chính. Không lấy debug signing làm production signing; không tự cài SDK.
- Chụp evidence nhận diện platform; release launch không được thay bằng ảnh golden.

Hoàn thành khi người khác có thể chạy sản phẩm và tái tạo các test chính theo
README mà không cần tác giả sửa code trực tiếp trên máy họ.

## 11. Gói G — Chọn tối đa một cải tiến tùy chọn

Chỉ thực hiện sau A–F hoặc khi không làm chậm các gate bắt buộc.

| Lựa chọn | Giá trị | Test cần có | Không mở rộng sang |
|---|---|---|---|
| Quick filters có chip biểu thị bộ lọc đang bật | Dễ hiểu vì sao task không xuất hiện | AND filters, clear từng chip/all, keyboard, semantics | Saved views/cloud preferences |
| Bộ phím tắt nhỏ có bảng hướng dẫn | Thao tác desktop nhanh và demo keyboard rõ | Shortcut không chiếm text input, focus đúng, enabled state | Remap phím, macro |
| Dark theme dùng chung token | Thêm trường hợp kiểm chứng contrast/golden | Light/dark ở compact/wide, error/status contrast | Theme marketplace, animation dày đặc |

Ưu tiên quick-filter chips nếu mục tiêu là dễ sử dụng và rủi ro thấp. Không thực
hiện cả ba. Với dark theme, chỉ lưu lựa chọn theme nếu có test isolation riêng;
không gộp cấu hình theme với dữ liệu tài khoản/password.

## 12. Quality gate và bằng chứng cho mỗi increment

Quy trình: test tái hiện/tiêu chí trước → code nhỏ → test hẹp → review diff →
full gate → ghi kết quả và giới hạn. Không tăng timeout vô căn cứ.

```text
dart format --output=none --set-exit-if-changed .
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --coverage
npm --prefix backend test
flutter test integration_test/windows_workflow_test.dart -d windows --no-pub
flutter test integration_test/independent_scenarios_test.dart -d windows --no-pub
flutter test integration_test/persisted_scenarios_test.dart -d windows --no-pub
scripts/test-online-windows.ps1 -NoPub
flutter build windows --release --no-pub
scripts/test-edge-harness.ps1 -Flutter <flutter.bat> -Sessions 1 -Repetitions 1 -NoPub
flutter build apk --release
```

Lệnh là mẫu; kiểm tra phiên bản và tham số trên máy thực thi. `--no-pub` chỉ dùng
sau khi dependencies đã resolve đúng lockfile. Chạy native suites riêng như hiện
tại. Script Edge khôi phục Web build với renderer cục bộ; không suy ra Web hoàn
toàn offline. APK ghi NOT RUN nếu thiếu toolchain, không tự cài để ép PASS.

Mỗi evidence bundle có: source SHA/worktree state, environment, command, dataset,
raw log, exit code, hình cần thiết, expected/actual, giải thích giới hạn và cách
tái tạo. Không lưu credentials, DB người dùng hoặc trace chứa token.

## 13. Liên hệ rubric và giá trị mong đợi

| Nhóm rubric | Nâng cấp hỗ trợ | Bằng chứng cần tạo |
|---|---|---|
| Technical depth / correctness | B/C | State transitions, conflict, failure recovery và regression tests |
| Experimental design / evidence | D | Baseline/fail/fix, workload và giới hạn đo |
| UX / cross-platform quality | B/E | Form an toàn, keyboard/Narrator, viewport và platform thật |
| Reproducibility | A/F | Traceability thống nhất, clean setup, gói release chạy được |
| Comparison / explanatory value | C/D | Vì sao chọn test level, vì sao không tự retry/merge |
| Professionalism | A/E/F | Metadata không đoán, log rõ, demo dễ theo dõi |

Những mục này tạo nguyên liệu cho bài, không tự động đạt điểm rubric báo cáo.
Vẫn cần nghiên cứu nguồn chính thống, nhóm tự tổng hợp, dùng template chính xác,
video tiếng Anh tối đa 20 phút và đóng góp có thể giải thích của từng thành viên.

## 14. Điểm dừng và trình tự đề xuất

1. Duyệt phạm vi và số ngày công; xác nhận còn thời gian cho đầu ra bắt buộc.
2. A → B → C; sau từng gói chốt test PASS và không còn mất dữ liệu/credentials.
3. D và E trên source ổn định; ưu tiên sửa lỗi quan sát được trước thêm tiện ích.
4. F, đóng băng tính năng. G chỉ chọn nếu còn ngân sách và không mở thêm rủi ro.
5. Bàn giao nguyên liệu đã xác thực cho báo cáo/video khi người dùng cho phép.

Hoãn một hạng mục nếu cần service trả phí/hosting/quyền mới, cần đổi kiến trúc
lớn, chưa có tiêu chí test rõ, hoặc vượt ước lượng hơn một ngày công mà chưa có
vertical slice chạy được. Khi đó thu hẹp hoặc dừng và xin nhóm quyết định.

Mốc nâng cấp thành công: luồng B/C chạy được, test phát hiện regression thật,
manual gaps được thực hiện hoặc ghi rõ, artifact tái tạo được, tài liệu thống nhất.
Không coi thêm tính năng là lý do được bỏ qua report/video hoặc thổi phồng bằng chứng.
