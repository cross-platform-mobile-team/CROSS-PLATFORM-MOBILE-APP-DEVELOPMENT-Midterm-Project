# Kịch bản quay video TaskFlow QA Lab

Bản có AI hỗ trợ, dành cho hai thành viên kiểm tra và tập trình bày. Phần chỉ dẫn bằng tiếng Việt; lời nói khi quay bằng tiếng Anh. Thời lượng mục tiêu 18 phút 30 giây, trần 20 phút theo đề 503107, mục V và VII. Phân vai dưới đây là đề xuất cho video, không phải xác nhận đóng góp thực tế.

## Chuẩn bị trước khi bấm quay

- Long: mở ứng dụng Windows, Android emulator API 36, mã nguồn và terminal; zoom code/log 140–160%. Hùng: mở sơ đồ kiến trúc, bộ test và bằng chứng. Cả hai phải hiểu và nói phần kỹ thuật có ý nghĩa.
- Quay 1920×1080, kiểm tra 20 giây âm thanh và chữ trên emulator. Tắt thông báo, che đường dẫn riêng nếu cần. Dùng tài khoản giả; không quay mật khẩu, token, recovery code hoặc dữ liệu thật.
- Dùng bản mã đã được nhóm duyệt. Ghi `git rev-parse --short HEAD` ở đầu phiên; không gọi kết quả tháng 10 là kết quả vừa chạy.
- Dùng workspace Sample cho thao tác phá dữ liệu; Sample không lưu qua phiên. Dùng Offline riêng để quay persistence. Không xóa toàn bộ preferences. Backend online phải là dữ liệu demo riêng.
- Chạy thử toàn bộ luồng trước. Mở sẵn cửa sổ kết quả PASS và các log FAIL gốc. Clip tua nhanh/cắt thời gian build phải có nhãn; không ghép kết quả của lệnh khác vào lệnh đang hiển thị.

Từ root repo, trong terminal PowerShell đã có Flutter trong PATH:

```powershell
flutter --version
flutter devices
git rev-parse --short HEAD
flutter pub get
./scripts/run-windows.ps1
```

Terminal backend riêng: `./scripts/run-backend.ps1`. Mặc định app desktop kết nối `http://127.0.0.1:8080`; Android emulator cần địa chỉ host `http://10.0.2.2:8080` và cấu hình debug phù hợp. Không hứa account mode của APK release truy cập HTTP debug. Nếu PATH thiếu Flutter, dùng resolver trong `scripts/resolve-flutter.ps1` hoặc đường dẫn SDK đã cài, không cài SDK trong lúc quay.

## 00:00–00:50 Giới thiệu — Long

Màn hình: tên đề tài, tên hai thành viên, mã số 523K0006 / 523K0014, app Windows. Xác nhận thông tin bìa trước khi thu.

Lời thoại:

“Hello, we are Nguyễn Bá Hùng and Nguyễn Bảo Long. Our topic is UI Automation Testing in Flutter, implementing end-to-end testing. TaskFlow is our task-management case study. We use it to investigate what different test levels can prove, how automation catches a real regression, and where platform evidence still has limits. We will show workflows, failure recovery, test code and recorded experiments on Windows and Android.”

Chuyển cảnh: “First, Hùng will explain how the testing layers divide these risks.”

## 00:50–02:20 Testing pyramid — Hùng

Màn hình: `docs/report/latex/assets/testing-layers.png`, rồi cây `test/` và `integration_test/`. Trỏ từng tầng khi nói.

“Unit tests isolate validation and search rules. Widget tests render Flutter UI in a controlled test environment and check interaction and state. Golden tests compare rendered pixels with reviewed baselines. Native integration tests run workflows in a target application and can cross real preferences or HTTP boundaries. Our browser harness provides another interaction boundary, but its controlled in-memory repository does not prove persistence.”

“We select tests by risk. A search-rule test gives fast feedback. A widget test checks that a user can discover the matching task. A native persisted scenario checks that records survive a repository remount. A separate release restart check is needed to demonstrate survival across process termination. These are different claims.”

Chỉ `pump` và completer trong một test: “A pump advances Flutter frames. We release controlled operations explicitly before waiting for settlement. An arbitrary delay can hide a race, while an unbounded animation can prevent settlement.”

## 02:20–03:20 So sánh và lựa chọn — Hùng

Màn hình: bảng so sánh trong chương 2; giữ chữ đủ lớn.

“Unit tests are isolated but cannot validate layout. Widget tests give strong Flutter interaction feedback but do not replace device execution. Goldens detect visual change and require controlled fonts and rendering. Integration tests exercise more boundaries, with higher setup and debugging cost. We use complementary layers rather than expecting one tool to cover every risk.”

“The historical timing experiment used unequal workloads and included command startup and native build overhead. It helps plan local feedback, but it is not a fair per-test benchmark or a universal ranking.”

## 03:20–04:30 Kiến trúc — Long

Màn hình: sơ đồ architecture; mở `task_controller.dart`, interface `task_repository.dart`, local và remote implementations.

“The presentation layer delegates operations to TaskController. The controller uses a repository interface, so tests can supply deterministic records and hold or fail operations. Clock and identifier seams avoid dependence on the current date or random identifiers. Local mode persists tasks in preferences. Account mode uses HTTP and SQLite, with ownership checks and revision-based snapshot writes. Sample mode is temporary and separate.”

“A successful load is required before mutation. This prevents an unknown or stale collection from overwriting stored data. A save publishes committed state only after the repository accepts it. Tokens stay in memory, and offline tasks are not silently uploaded when signing in.”

## 04:30–07:10 Demo Windows — Long

Chuẩn bị dữ liệu: `Review Flutter testing`, `Write report`, `Record demo`; priority và ngày khác nhau. Đặt ngày qua date picker để không phụ thuộc ngày trong kịch bản.

1. Vào Sample; chỉ nhãn chế độ. Thử submit tiêu đề trống. Kết quả: lỗi validation rõ, không thêm task. Nói: “An invalid submit must preserve the form and explain the correction.”
2. Tạo `Review Flutter testing`, notes `Check regression evidence`, priority High, chọn ngày và tag `testing`. Kết quả: task xuất hiện đúng metadata.
3. Tạo `Write report` priority thấp hơn. Search ` FLUTTER `, chỉ còn task đầu; gõ giữa từ để nhấn mạnh substring. Nói: “Search trims and normalizes input. A matching word does not need to begin the title.”
4. Bật filter thích hợp, đổi sort, chỉ điều kiện đang active. Xóa riêng search rồi xóa filter, giải thích hai thao tác khác nhau. Không khẳng định exact order nếu chưa kiểm tra dữ liệu seed.
5. Edit notes; Cancel rồi chọn tiếp tục sửa khi có cảnh báo draft; Save. Kết quả: metadata giữ đúng và không nhân đôi task.
6. Mark complete; chỉ trạng thái và count. Delete task thứ hai, Confirm, Undo. Kết quả: task quay lại và metadata được giữ.

Lời nối: “Visible feedback matters, but our tests also inspect identity, metadata, unaffected tasks and persisted state. A button click alone is a weak oracle.”

## 07:10–08:40 Android và persistence — Long

Màn hình: emulator, có nhãn Android 16/API 36; thu trực tiếp thao tác thực tế.

1. Vào Offline trên emulator, tạo task `Video persistence check` bằng dữ liệu giả.
2. Chỉ compact layout, thao tác sửa và complete; không che mất kết quả bằng bàn phím.
3. Dùng app info Force stop rồi mở lại đúng app; không Clear storage. Nếu dùng adb, xác định package từ cấu hình trước, không đoán package.
4. Task vẫn hiện: nói kết quả vừa quan sát. Nếu không còn, dừng và điều tra, không lấy clip cũ giả thành hiện tại.

“This is an Android emulator, not a physical phone. This offline task remains after force-stop and relaunch. That is a process boundary, stronger than remounting widgets. It does not prove operating-system reboot recovery or release account connectivity. Native automated typing also uses a test channel and does not validate every input method.”

## 08:40–10:20 Chạy và giải thích test — Hùng

Màn hình: chạy một test nhanh rồi mở suite summary tháng 10, ghi rõ ngày.

```powershell
flutter test test/widget/search_regression_test.dart --reporter expanded
flutter test test/widget/uiux_recovery_test.dart --reporter expanded
```

Nếu tên file recovery trên revision quay khác, kiểm tra `rg --files test` trước; không hiển thị lệnh chưa tồn tại. Mở `docs/evidence/uiux-audit-20261011/uiux-final-coverage.log` và README cùng thư mục.

“The recorded October suite passed 133 Flutter cases, including golden comparisons and five controlled recovery scenarios. Seventeen API cases and fifteen named native scenarios per platform are recorded separately. These are overlapping platform executions. Most Windows native selections preceded the final replacement-ID correction; the online selection was rerun afterward. The current terminal shows only the tests we have just executed.”

Mở test pending: chỉ thao tác giữ request, assert busy, thả completer, assert kết quả. Nói: “The test observes the pending interval deliberately, checks duplicate-submit prevention, then releases the operation. This exposes a race more reliably than hoping a slow request lasts long enough.”

## 10:20–11:50 Recovery và xung đột — Hùng

Màn hình: `uiux_recovery_test.dart`, baseline `audit-edit-recovery.png`, log kết quả thật. Dùng test kiểm soát để demo lỗi thay vì tắt mạng tùy tiện và gọi đó là cùng lỗi.

“A failed response does not always mean the server rejected the write. The server may have committed before the client timed out. The recovery UI retains editable fields and offers explicit reload, comparison and application. Reload alone must not write. A replacement task reserves its identifier, so a lost response does not produce duplicate replacements.”

Chỉ assertion giữ server completion status và no duplicate replacement trong test. “These five cases use fake HTTP responses. They verify client decisions deterministically. The separate online native case crosses the real API and isolated SQLite store. Neither alone establishes production network reliability.”

## 11:50–14:10 Intentional defect — Hùng

Màn hình: `docs/evidence/intentional_defect/README.md`, `buggy.patch`, `fail.txt`, `fix.patch`, `pass.txt`, test source.

Phương án ưu tiên khi quay: trình bày log gốc với nhãn “Recorded experiment, 6 September 2026”, rồi chạy regression đúng hiện tại. Nếu muốn quay live injection, chỉ làm trên checkout riêng đã chuẩn bị trước; đọc README, `git apply --check` trước, giữ cùng test/fixture, áp dụng fix trong `finally`, xác nhận source sạch. Không sửa production worktree đang chứa báo cáo chưa commit.

“Our correct rule is normalized substring search. The fixture includes Review Flutter testing and Write report. The query contains uppercase FLUTTER with surrounding whitespace. The correct task must remain visible. We temporarily replace contains with startsWith. Compilation can still succeed, but the title no longer matches because Flutter occurs after Review.”

Mở fail đúng lỗi mất task, không chỉ exit code. “This is a semantic defect, not a syntax error. The oracle looks for the task widget and excludes the unrelated task. Seeing the query text in the input would not be sufficient.”

Mở fix và pass cùng test: “Restoring contains makes the same regression pass. We retain baseline, failing output, patches and corrected output. One defect and one run at each stage demonstrate this detection; they do not estimate a general detection probability. The corrected implementation and permanent test remain in the final source.”

## 14:10–15:40 Hiệu năng — Long

Màn hình: bảng Windows profile trong báo cáo; mở `docs/evidence/uiux-audit-20261011/profile-metrics.json` khi cần trace.

“The October experiment compared eager construction with SliverList in Windows profile mode. Each strategy had one complete run with 100 and 500 synthetic tasks and long notes. For 500 tasks, mean build time during search changed from 179.163 to 6.511 milliseconds; during scrolling, from 37.278 to 0.380 milliseconds. Stable keys and a child-index callback preserve identity during reorder, while focused actions and expanded notes can request keep-alive.”

“These are engine build-time samples, not FPS and not widget-test duration. Frame sample counts differ. One host and one run per strategy limit generalization, and some lazy search frames still exceed 16.67 milliseconds. We have not measured physical Android performance or backend throughput here.”

## 15:40–16:50 Accessibility và giới hạn — Hùng

Màn hình: compact golden, semantics test, ảnh TalkBack evidence; ghi “Recorded compatibility check”.

“Status and priority have text, important controls have semantics, and tests cover compact layout and text scaling. TalkBack 16.0 was bound with touch exploration. The evidence shows focus, Tab traversal and task creation. This is basic compatibility evidence. Speech quality, physical swipe and double-tap completion and a full screen-reader audit remain unverified. Windows Narrator and iOS are not run.”

“The Android build also exposed a host Java loopback problem. A scoped TCP fallback allowed the release build; original failures remain in the evidence. This is a host workaround and does not justify changing global Java behavior.”

## 16:50–18:00 Tái tạo và kết luận — cả hai

Màn hình: README, source/test folders, evidence index và report; mở release checksum đã ghi, không tuyên bố file hiện tại khớp nếu chưa hash lại.

Long: “The repository includes Flutter source, lockfiles, platform configuration, tests, configuration examples and evidence. The README explains setup and reproducible workflows. Build products and local databases should stay outside source control. We retain genuine failed logs because they explain what was corrected.”

Hùng: “Our main result is a defensible testing case study. Isolated fixtures and meaningful assertions provide fast diagnosis; native and real-server workflows cross additional boundaries. Reviewed goldens protect presentation, while measured experiments and explicit limitations keep our conclusions proportionate to the evidence.”

Long: “For this presentation, I demonstrated architecture, product workflows, Android persistence and profiling.” Hùng: “I explained testing strategy, recovery assertions and the intentional regression.” Chỉ dùng các câu này nếu đúng phần hai người đã thực sự trình bày; đóng góp dự án phải xác nhận riêng.

## 18:00–18:30 Buffer và kiểm tra bản quay

Không thêm tính năng mới ở cuối. Chừa 30 giây cho chuyển cảnh và kết luận tự nhiên. Nếu quá 20 phút, rút thời gian chờ build và thao tác lặp; giữ defect fail/fix/pass, hai nền tảng, giới hạn và phần nói của cả hai.

## Khi có sự cố

| Sự cố | Xử lý khi quay |
| --- | --- |
| Test mất nhiều thời gian build | Dừng thu đoạn chờ hoặc tua có nhãn; giữ lệnh, lỗi/thành công và exit code |
| Backend/emulator không sẵn | Chuẩn bị lại trước khi thu; nếu dùng log cũ phải hiện ngày và nền tảng |
| Patch không áp dụng trên revision mới | Không force; dùng log/patch gốc và giải thích lịch sử, hoặc sửa patch có review trên checkout riêng |
| Golden fail do môi trường | Lưu diff và chẩn đoán; không regenerate chỉ để có PASS |
| Task không giữ sau restart | Giữ clip lỗi để điều tra, sửa và quay lại; không thay thế bằng kết quả khác |
| Lộ tài khoản/recovery code | Dừng thu, loại đoạn lộ và đổi/thu hồi thông tin liên quan trước khi chia sẻ |

## Checklist bản cuối

- Video tiếng Anh, dưới 20 phút, giọng hai người nghe rõ, chữ code/log đọc được.
- Có input → trạng thái/xử lý → output; validation, recovery, persistence, hai nền tảng và defect.
- Mọi số liệu có ngày, môi trường và evidence đúng; không gọi log lịch sử là live.
- Không có recovery code/token/password; không đưa tài khoản demo thật vào Git.
- Hai thành viên kiểm tra tên/MSSV, hiểu phần code được quay và tập câu hỏi vấn đáp.
- Nhóm xác nhận đóng góp thực tế và khai báo hỗ trợ AI theo yêu cầu giảng viên trước khi nộp.
