# BOD Financial Dashboard

## Cấu trúc file

```
bod-dashboard/
├── index.html      ← Dashboard public (share link cho BOD)
├── admin.html      ← Backend nhập liệu (password protected)
├── setup.sql       ← Chạy 1 lần trên Supabase SQL Editor
└── README.md
```

---

## Hướng dẫn cài đặt

### Bước 1 — Supabase: Tạo tables

1. Vào https://supabase.com → project của bạn
2. Mở **SQL Editor**
3. Copy toàn bộ nội dung `setup.sql` và chạy
4. Kiểm tra trong **Table Editor** — phải thấy 7 tables: `bod_config`, `bod_pnl`, `bod_balance_sheet`, `bod_cashflow`, `bod_monthly_revenue`, `bod_project_revenue`, `bod_monthly_kpi`

### Bước 2 — Điền Supabase credentials vào 2 file HTML

Trong `index.html`, tìm dòng:
```js
const SB_URL = localStorage.getItem('bod_sb_url') || 'https://YOUR_PROJECT.supabase.co';
const SB_KEY  = localStorage.getItem('bod_sb_key') || 'YOUR_ANON_KEY';
```

Trong `admin.html`, tìm dòng:
```js
let SB_URL = localStorage.getItem('bod_sb_url') || '';
let SB_KEY  = localStorage.getItem('bod_sb_key') || '';
if(!SB_URL) SB_URL = 'https://YOUR_PROJECT.supabase.co';
if(!SB_KEY) SB_KEY  = 'YOUR_ANON_KEY';
```

Thay `YOUR_PROJECT` và `YOUR_ANON_KEY` bằng:
- **Project URL**: Supabase → Settings → API → Project URL
- **Anon Key**: Supabase → Settings → API → Project API keys → `anon public`

> Hoặc: sau khi deploy, vào `admin.html` → tab **Cấu hình** → điền URL & Key → Lưu kết nối (lưu vào localStorage)

### Bước 3 — Deploy lên GitHub Pages

1. Tạo repo mới trên GitHub (ví dụ: `financial-dashboard`)
2. Upload 3 file: `index.html`, `admin.html`, `setup.sql`
3. Vào **Settings → Pages → Source: Deploy from branch → main → / (root)**
4. GitHub tự deploy sau ~2 phút

URLs sau khi deploy:
- Dashboard: `https://[username].github.io/financial-dashboard/`
- Admin: `https://[username].github.io/financial-dashboard/admin.html`

### Bước 4 — Đổi mật khẩu Admin

Trong `admin.html`, tìm và thay:
```js
const ADMIN_PWD = 'BOD2026';
```

---

## Workflow cập nhật data hàng tháng

1. Mở `admin.html` → đăng nhập
2. Tab **Doanh thu tháng** → chọn tháng → nhập số liệu → Lưu
3. Tab **KPI vận hành** → chọn tháng → nhập → Lưu
4. Tab **Theo dự án** → chọn tháng → nhập breakdown → Lưu
5. Chia sẻ link `index.html` cho BOD — data tự cập nhật

## Cập nhật BCTC 2025 (1 lần)

1. Tab **P&L / Kết quả KD** → nhấp trực tiếp vào ô số để sửa → Lưu
2. Tab **Bảng CĐKT** → sửa tương tự
3. Tab **Lưu chuyển tiền** → sửa tương tự

---

## Tùy chỉnh

### Đổi tên công ty
Admin → tab **Cấu hình** → Tên công ty → Lưu

### Đổi mảng kinh doanh
Trong `admin.html` tìm:
```js
const SEGMENTS = [
  { key:'primary',   label:'Sơ cấp' },
  { key:'branded',   label:'Branded' },
  ...
];
```
Sửa `label` theo tên thực của công ty bạn.

### Thêm năm mới
Trong select `yr-select` của `index.html`, thêm:
```html
<option value="2027">2027</option>
```
