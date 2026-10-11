# Kịch bản test thủ công TaskFlow

Ngày chuẩn bị: 11/10/2026. Đây là checklist để bạn thực hiện, chưa phải kết quả kiểm thử của bạn.

## 1. Mở ứng dụng và chuẩn bị

- Frontend: http://127.0.0.1:7357 — bản web release đã build từ source hiện tại.
- Backend: http://127.0.0.1:8080/health — phải trả JSON có `status: ok`.
- API reference: http://127.0.0.1:8080/openapi.json.
- Giữ nguyên origin `127.0.0.1:7357` trong suốt lượt test để kiểm tra dữ liệu offline.
- Tạo tài khoản test mới, ví dụ `qa.a.20261011.2155@example.test` và `qa.b.20261011.2155@example.test`; đổi hậu tố nếu đã tồn tại. Display name: `QA Alice`, `QA Bob`. Mật khẩu thử nghiệm: `TaskFlow-Test!2026` (không dùng cho tài khoản thật).
- Lưu recovery code của tài khoản test để thực hiện ca khôi phục. Ứng dụng không gửi email xác minh/reset.
- D0 = ngày hiện tại trên máy; D−1 = hôm qua; D+1 = ngày mai. Nhập ngày theo `YYYY-MM-DD`.
- Với ca hai phiên, mở hai cửa sổ trình duyệt tại cùng URL và đăng nhập A vào cả hai. App giữ token trong bộ nhớ: refresh trang có thể đưa về Sign in; đăng nhập lại để xem dữ liệu đã lưu.

### Bộ dữ liệu nhỏ

Tạo trong tài khoản A bằng cách mở **Task details (optional)**:

| Mã | Title | Notes | Priority | Due date | Tags | Trạng thái |
|---|---|---|---|---|---|---|
| A1 | Alpha report | Prepare diagrams and test evidence | high | D+1 | Course, flutter, course | Pending |
| A2 | Beta review | Review the release checklist | medium | D−1 | course, review | Pending |
| A3 | Gamma slides | Practice the presentation | low | để trống | slides | Completed: tick sau khi tạo |

Tags của A1 phải được chuẩn hóa thành `course`, `flutter`, không có `course` lặp lại.

## 2. Lượt nhanh 10–15 phút

Thực hiện TC01 → TC03 → TC04 → TC06 → TC07 → TC09 → TC10 → TC12. Các ca còn lại dành cho lượt đầy đủ khoảng 30–45 phút, chưa tính ghi lỗi/chụp ảnh.

## 3. Tài khoản và tác vụ

| ID | Thao tác | Kết quả mong đợi |
|---|---|---|
| TC01 — Đăng ký/validation | Bấm Create account. Để trống và submit; nhập email sai; nhập confirm password khác; cuối cùng nhập tài khoản A hợp lệ và hai password khớp nhau. | Có lỗi cạnh trường cần sửa; không tạo account ở dữ liệu sai. Đăng ký hợp lệ hiển thị recovery code. Copy có phản hồi; bấm I saved my recovery code vào workspace online. |
| TC02 — Đăng nhập sai/đúng | Sign out qua Account settings. Đăng nhập A với mật khẩu sai rồi đúng. | Sai: báo lỗi, vẫn sửa được form. Đúng: vào dữ liệu riêng của A. Không tạo phiên đăng nhập thành công với mật khẩu sai. |
| TC03 — Tạo và chuẩn hóa | Tạo A1, A2, A3 theo bảng; tick A3. Bấm Add task nhanh hai lần trong cùng thao tác thử. | Có đúng 3 task mẫu; lần submit đang chờ không tạo trùng. Tổng 3, Pending 2, Completed 1. A1 giữ đủ metadata và tags được chuẩn hóa. Nếu mạng quá nhanh để quan sát trạng thái chờ, dùng TC13. |
| TC04 — Validation task | Thử title chỉ chứa dấu cách, title >120 ký tự; notes >2000; ngày `2026-02-30`; hơn 10 tags hoặc tag >24 ký tự. Sau mỗi lần, sửa về dữ liệu hợp lệ. | Không lưu bản sai; control ngăn nhập quá giới hạn hoặc báo validation hữu ích và focus/reveal trường lỗi. Bản nháp các trường khác còn nguyên. Giới hạn đạt đúng mức tối đa được phép phải lưu được. |
| TC05 — Sửa/hủy bản nháp | Edit A1; đổi title/notes/tags nhưng Cancel hoặc Escape. Chọn Continue editing; thử lại và chọn bỏ thay đổi. Sau đó Edit và Save changes với dữ liệu hợp lệ. | Có xác nhận khi bỏ bản nháp đã sửa; Continue editing giữ nội dung. Hủy không đổi task đã lưu. Save lưu đúng toàn bộ trường. Ghi lại title hiện tại để dùng các ca sau. |
| TC06 — Hoàn thành/ngày | Kiểm tra A2 quá hạn; tick A2, rồi bỏ tick. | Khi Pending: hiển thị Overdue. Khi Completed: không còn cảnh báo Overdue. Bỏ tick: Pending/Overdue trở lại; thống kê thay đổi đúng. |
| TC07 — Xóa/Undo | Delete A2 rồi Cancel. Delete lại và xác nhận; bấm Undo delete. | Cancel giữ A2. Xác nhận xóa đúng A2. Undo khôi phục title, notes, date, priority, tags và trạng thái; A1/A3 không đổi. Undo chỉ giữ lần xóa gần nhất trong phiên app. |
| TC08 — Notes dài | Sửa notes A1 thành nhiều dòng trong giới hạn; lưu; bấm Show more rồi Show less. | Card có preview gọn; mở rộng xem đủ notes, thu gọn được. Edit/Delete và metadata vẫn dùng được. |
| TC09 — Search/filter AND | Search `diagrams` (hoặc từ còn trong notes A1). Mở Filter and sort: Status Pending, Priority high, Exact tag course, Due date Upcoming; Apply. | Chỉ A1 khớp đồng thời mọi điều kiện. Search tìm trong title/notes/tags. Đổi tag thành giá trị không có: không có kết quả, có hành động xóa điều kiện. |
| TC10 — Gỡ filter/reset/sort | Chọn Title A–Z; giữ search đang có. Xóa riêng chip priority hoặc tag; sau đó Reset filters. Cuối cùng clear search bằng nút x của search. | Xóa chip chỉ bỏ điều kiện đó. Reset filters giữ search và sort. Clear search chỉ xóa search. Khi không còn lọc/search: thứ tự title tăng dần theo title hiện tại, nhãn sort và số kết quả đúng. |
| TC11 — Task mới bị ẩn | Chọn chip Completed. Tạo task mới tên Hidden pending test. Khi có thông báo task bị ẩn, bấm View task. | Task Pending không khớp Completed nhưng vẫn được tạo đúng một lần. Có phản hồi thành công. View task đưa tới task vừa tạo và mở Edit; bản nháp quick-create mới nhập sau khi submit không bị mất. |
| TC12 — Dữ liệu qua phiên/tài khoản | Sign out A, đăng nhập B; tạo Bob private task. Sign out B rồi vào A; refresh tab và đăng nhập A lại nếu cần. | B không thấy task của A. A không thấy Bob private task. Task đã lưu của A còn sau đăng nhập lại/refresh. Quick-create chưa lưu không được cam kết giữ qua refresh trình duyệt. |

## 4. Request chậm, mất mạng và hai phiên

DevTools → Network chỉ áp dụng cho tab đang kiểm tra. Sau ca chậm/mất mạng, đưa về **No throttling** và bỏ **Offline**.

| ID | Thao tác | Kết quả mong đợi |
|---|---|---|
| TC13 — Request đang chờ | Chọn Slow 3G. Gửi quick-create tên Request one; khi đang Adding…, nhập title/metadata cho Request two. Chờ request đầu hoàn tất. | Chỉ Request one được lưu. Form giữ bản nháp Request two. Nút submit chống gửi lặp khi đang chờ. Nhãn Adding… phân biệt với Saving…/Deleting…/Restoring… ở các thao tác tương ứng. |
| TC14 — Mất mạng khi Edit | Edit A1 và thay cả title/notes/date/tags. Bật Offline rồi Save changes. Khi báo lỗi, tắt Offline; bấm Load latest; keep my draft. Mở Latest saved version; sau khi xem, chọn Apply my draft. | Form không mất bản nháp. Sau lỗi, không blind retry write. Load latest chỉ tải lại/so sánh. Chỉ quyết định Apply mới ghi; task sau cùng có đúng các trường bạn chọn. Nếu reload vẫn lỗi, form tiếp tục giữ draft. |
| TC15 — 409, giữ draft | Hai cửa sổ X/Y cùng đăng nhập A và tải cùng danh sách. X Edit A1, nhập draft nhưng chưa Save. Y Edit A1, đổi title thành Server changed và lưu. X Save changes; rồi Load latest; keep my draft và mở Latest saved version. | X nhận conflict; draft X còn đủ các trường. So sánh thấy bản Y đã lưu. Không tự ghi đè Y khi reload. Apply my draft là quyết định ghi đè các trường editable bằng draft X. Đóng/hủy thay vì Apply thì bản Y được giữ. |
| TC16 — Task bị xóa ở phiên khác | X/Y tải cùng danh sách A. X Edit một task thử mới, nhập draft. Y xóa task đó. X Save; Load latest; keep my draft; chọn Save as new task. | Có thông báo task đã bị xóa; draft còn nguyên. Chỉ quyết định Save as new task mới tạo task thay thế; một task mới, đủ metadata, không âm thầm khôi phục ID cũ. |

**Giới hạn ca thủ công:** bật Offline trước Save không chứng minh timeout xảy ra *sau khi server đã commit*. Không cố tạo ngẫu nhiên rồi kết luận PASS. Trường hợp commit nhưng mất phản hồi, kể cả lưu lại task đã bị xóa, đã có regression kiểm soát trong `test/widget/uiux_recovery_test.dart`. Muốn kiểm tra tay đúng thời điểm cần proxy/harness chặn phản hồi; checklist này không giả lập điều đó.

## 5. Local/sample, settings và accessibility

| ID | Thao tác | Kết quả mong đợi |
|---|---|---|
| TC17 — Local và sample | Sign out. Use offline demo; tạo Local only. Return to sign in. Try sample sandbox; sửa/xóa một sample; Exit sample sandbox và vào sample lại. Cuối cùng vào offline lại và đăng nhập A kiểm tra. | Local only còn trong offline trên cùng origin. Sample quay lại bộ mẫu ban đầu; không làm mất Local only. Account A tách biệt cả local và sample; không có tự động upload. |
| TC18 — Guard quick-create | Trong local hoặc sample, nhập title và metadata nhưng chưa Add. Bấm Return to sign in/Exit sample sandbox. Chọn Continue editing, rồi thử bỏ draft và rời đi. | Có xác nhận bỏ draft. Continue editing giữ title và metadata. Chỉ chọn Discard and leave mới rời workspace. |
| TC19 — Profile/password | Vào Account settings của A. Back khi chưa sửa; sửa Display name rồi Back → Continue editing; đổi tên trở lại tên ban đầu và Back. Sau đó Save profile với tên mới. Thử show/hide Current password/New password. | Chưa sửa hoặc đã hoàn nguyên: không hỏi bỏ draft. Có sửa chưa lưu: hỏi trước khi rời. Lưu tên thành công; trường mật khẩu show/hide rõ. Password không được lưu thành draft qua việc đóng settings. |
| TC20 — Sessions và password | Mở X/Y đăng nhập A. Ở X xem Sessions và thu hồi phiên Y nếu nhận diện được; Y Reload server tasks. Sau đó đổi password của A bằng current password đúng. | Y hết quyền sau khi phiên bị thu hồi và thực hiện request mới. Đổi password báo thành công và yêu cầu đăng nhập lại; mật khẩu cũ không đăng nhập được, mật khẩu mới được. Ghi lại mật khẩu test mới để ca sau dùng đúng. |
| TC21 — Recovery | Sign out. Forgot password?; nhập email A, recovery code đã lưu và password mới. Thử đăng nhập bằng password mới; lưu recovery code thay thế. | Khôi phục thành công phát code mới; code cũ đã dùng không tái sử dụng được. Các phiên cũ bị thu hồi. Đây là code recovery, không phải luồng gửi email. |
| TC22 — Responsive/keyboard | DevTools đổi viewport 360×800, 390×844, 768×1024, 1280×900. Nhập draft rồi resize. Thử zoom 200%, Tab/Shift+Tab, Enter trong trường phù hợp, Escape trong Edit. | Không overflow ngang, mất nội dung hay nút không tới được bằng cuộn. Draft giữ khi resize. Focus thấy rõ, thứ tự hợp lý; Edit có thể hủy an toàn. 390×844 với task ngắn/trạng thái thường phải thấy trọn task đầu. Browser zoom không thay thế kiểm tra text scale native Android. |
| TC23 — Screen reader | Nếu có screen reader, đi lần lượt qua sign-in, password toggle, status chips, task checkbox, Edit/Delete, thông báo lưu và dialog bỏ draft. Ghi lại lời đọc, thứ tự focus và thao tác kích hoạt. | Tên control và trạng thái được đọc đúng, không ghép toàn màn hình thành một nhãn, không mắc kẹt focus. Đây là ca cần người nghe/thao tác thực tế; dấu focus hoặc widget semantics tự động không đủ để đánh dấu toàn ca PASS. |
| TC24 — Cleanup tùy chọn | Chỉ trong các account test mới tạo: Delete my account, nhập đúng password, xem xác nhận rồi quyết định xóa. Trong local, chỉ xóa task thử của lượt này. | Cancel không xóa. Xác nhận xóa account test kết thúc phiên và không đăng nhập lại được. Không xóa dữ liệu cá nhân hay account đã tồn tại trước lượt test. |

## 6. Ghi kết quả

Mỗi ca chọn PASS / FAIL / NOT RUN. Chỉ PASS khi thực tế khớp toàn bộ kết quả mong đợi.

| ID | Kết quả | Actual result / lỗi | Ảnh hoặc video | Trình duyệt, viewport |
|---|---|---|---|---|
| TC__ | | | | |

Khi gặp lỗi, ghi: bước tái hiện chính xác; account test/loại workspace; expected và actual; thời điểm; ảnh; HTTP status trong Network nếu có. Che password, token và recovery code trước khi chia sẻ ảnh/log. Với request lỗi, ghi rõ đã xảy ra trước hay sau phản hồi; nếu chưa biết thì ghi chưa xác định.

## 7. Trạng thái phiên chạy

Backend đang dùng database local hiện có của dự án theo default `backend/data/taskflow.sqlite`. Không tự reset database. Frontend được phục vụ từ `build/web`; đây là bản release nên sửa source không tự hot reload. Nếu bạn sửa code và muốn xem bản mới, cần build web lại hoặc chạy Flutter dev server.

Cả hai dịch vụ chạy cục bộ trên 127.0.0.1. Để dừng chúng trong phiên hiện tại, xem PID/URL ở `outputs/taskflow-running-services.json` và đối chiếu command line của process trước khi dừng. Các PID chỉ đúng trong phiên chạy này.
