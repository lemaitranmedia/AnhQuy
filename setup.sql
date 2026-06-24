-- ============================================================
-- BOD FINANCIAL DASHBOARD — Supabase Setup Script
-- Chạy toàn bộ script này 1 lần trong Supabase SQL Editor
-- ============================================================

-- 1. CONFIG: Thông tin công ty (1 row duy nhất)
CREATE TABLE IF NOT EXISTS bod_config (
  id          TEXT PRIMARY KEY DEFAULT 'main',
  company     TEXT NOT NULL DEFAULT 'Tên công ty',
  fiscal_year INT  NOT NULL DEFAULT 2025,
  currency    TEXT NOT NULL DEFAULT 'tỷ đồng',
  updated_at  TIMESTAMPTZ DEFAULT now()
);
INSERT INTO bod_config (id, company, fiscal_year, currency)
VALUES ('main', 'Tên công ty', 2025, 'tỷ đồng')
ON CONFLICT (id) DO NOTHING;

-- 2. PNL: Báo cáo kết quả kinh doanh (dòng theo năm)
CREATE TABLE IF NOT EXISTS bod_pnl (
  id            SERIAL PRIMARY KEY,
  year          INT  NOT NULL,
  label         TEXT NOT NULL,        -- Tên chỉ tiêu
  row_order     INT  NOT NULL,        -- Thứ tự hiển thị
  row_type      TEXT NOT NULL DEFAULT 'normal', -- 'bold' | 'sub' | 'total' | 'spacer'
  value         NUMERIC(18,2),
  budget        NUMERIC(18,2),        -- Kế hoạch
  note          TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, row_order)
);

-- 3. BALANCE SHEET: Bảng cân đối kế toán
CREATE TABLE IF NOT EXISTS bod_balance_sheet (
  id            SERIAL PRIMARY KEY,
  year          INT  NOT NULL,
  section       TEXT NOT NULL,        -- 'assets' | 'liabilities' | 'equity'
  label         TEXT NOT NULL,
  row_order     INT  NOT NULL,
  row_type      TEXT NOT NULL DEFAULT 'normal',
  value         NUMERIC(18,2),
  note          TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, section, row_order)
);

-- 4. CASH FLOW: Báo cáo lưu chuyển tiền tệ
CREATE TABLE IF NOT EXISTS bod_cashflow (
  id            SERIAL PRIMARY KEY,
  year          INT  NOT NULL,
  section       TEXT NOT NULL,        -- 'operating' | 'investing' | 'financing'
  label         TEXT NOT NULL,
  row_order     INT  NOT NULL,
  row_type      TEXT NOT NULL DEFAULT 'normal',
  value         NUMERIC(18,2),
  note          TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, section, row_order)
);

-- 5. MONTHLY REVENUE: Doanh thu hàng tháng theo mảng
CREATE TABLE IF NOT EXISTS bod_monthly_revenue (
  id              SERIAL PRIMARY KEY,
  year            INT  NOT NULL,
  month           INT  NOT NULL CHECK (month BETWEEN 1 AND 12),
  segment         TEXT NOT NULL,      -- 'primary' | 'branded' | 'secondary' | 'service' | 'total'
  revenue         NUMERIC(18,2) DEFAULT 0,
  budget          NUMERIC(18,2) DEFAULT 0,
  note            TEXT,
  updated_at      TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, month, segment)
);

-- 6. PROJECT REVENUE: Doanh thu theo dự án (tùy chọn)
CREATE TABLE IF NOT EXISTS bod_project_revenue (
  id              SERIAL PRIMARY KEY,
  year            INT  NOT NULL,
  month           INT  NOT NULL CHECK (month BETWEEN 1 AND 12),
  project_name    TEXT NOT NULL,
  segment         TEXT NOT NULL,
  revenue         NUMERIC(18,2) DEFAULT 0,
  updated_at      TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, month, project_name)
);

-- 7. OPERATING KPIs: Chỉ số vận hành hàng tháng
CREATE TABLE IF NOT EXISTS bod_monthly_kpi (
  id              SERIAL PRIMARY KEY,
  year            INT  NOT NULL,
  month           INT  NOT NULL CHECK (month BETWEEN 1 AND 12),
  deals_closed    INT  DEFAULT 0,     -- Số deal chốt
  deals_pipeline  INT  DEFAULT 0,     -- Số deal đang xử lý
  conversion_rate NUMERIC(5,2) DEFAULT 0, -- Tỉ lệ chốt (%)
  new_customers   INT  DEFAULT 0,     -- Khách hàng mới
  active_customers INT DEFAULT 0,     -- Khách hàng đang theo dõi
  avg_deal_size   NUMERIC(18,2) DEFAULT 0, -- Giá trị deal TB
  note            TEXT,
  updated_at      TIMESTAMPTZ DEFAULT now(),
  UNIQUE(year, month)
);

-- ============================================================
-- RLS: Cho phép đọc public (dashboard BOD), ghi cần anon key
-- ============================================================
ALTER TABLE bod_config          ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_pnl             ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_balance_sheet   ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_cashflow        ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_monthly_revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_project_revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE bod_monthly_kpi     ENABLE ROW LEVEL SECURITY;

-- Policy: anon có thể đọc và ghi tất cả (admin.html dùng anon key + password riêng)
CREATE POLICY "public_read"  ON bod_config          FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_config          FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_pnl             FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_pnl             FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_balance_sheet   FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_balance_sheet   FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_cashflow        FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_cashflow        FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_monthly_revenue FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_monthly_revenue FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_project_revenue FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_project_revenue FOR ALL    USING (true);
CREATE POLICY "public_read"  ON bod_monthly_kpi     FOR SELECT USING (true);
CREATE POLICY "public_write" ON bod_monthly_kpi     FOR ALL    USING (true);

-- ============================================================
-- SEED DATA: Dummy PnL 2025
-- ============================================================
INSERT INTO bod_pnl (year, label, row_order, row_type, value, budget) VALUES
(2025, 'DOANH THU',                    1,  'bold',   NULL,   NULL),
(2025, 'Doanh thu thuần',              2,  'total',  1284,   1250),
(2025, 'Doanh thu mảng chính',         3,  'sub',    897,    870),
(2025, 'Doanh thu phụ trợ & dịch vụ', 4,  'sub',    387,    380),
(2025, 'GIÁ VỐN & LỢI NHUẬN GỘP',    5,  'bold',   NULL,   NULL),
(2025, 'Giá vốn dịch vụ',             6,  'normal', 872,    840),
(2025, 'Lợi nhuận gộp',               7,  'total',  412,    410),
(2025, 'Biên lợi nhuận gộp (%)',       8,  'sub',    32.1,   32.8),
(2025, 'CHI PHÍ VẬN HÀNH',            9,  'bold',   NULL,   NULL),
(2025, 'Chi phí nhân sự',              10, 'sub',    207,    190),
(2025, 'Chi phí bán hàng',             11, 'sub',    62,     58),
(2025, 'Chi phí marketing & events',   12, 'sub',    51,     48),
(2025, 'Chi phí quản lý',              13, 'sub',    104,    95),
(2025, 'Tổng chi phí vận hành',        14, 'total',  424,    391),
(2025, 'KẾT QUẢ',                     15, 'bold',   NULL,   NULL),
(2025, 'EBITDA',                       16, 'total',  218,    223),
(2025, 'Biên EBITDA (%)',              17, 'sub',    17.0,   17.8),
(2025, 'Khấu hao & lãi vay',          18, 'normal', 76,     75),
(2025, 'Lợi nhuận trước thuế',         19, 'normal', 178,    185),
(2025, 'Thuế TNDN',                    20, 'normal', 36,     37),
(2025, 'Lợi nhuận sau thuế (LNST)',   21, 'total',  142,    148),
(2025, 'Biên LNST (%)',               22, 'sub',    11.1,   11.8)
ON CONFLICT (year, row_order) DO NOTHING;

-- SEED: Balance Sheet 2025
INSERT INTO bod_balance_sheet (year, section, label, row_order, row_type, value) VALUES
(2025, 'assets', 'TÀI SẢN NGẮN HẠN',           1,  'bold',   NULL),
(2025, 'assets', 'Tiền & tương đương tiền',       2,  'normal', 185),
(2025, 'assets', 'Phải thu ngắn hạn',             3,  'normal', 312),
(2025, 'assets', 'Hàng tồn kho',                  4,  'normal', 68),
(2025, 'assets', 'Tài sản ngắn hạn khác',         5,  'normal', 42),
(2025, 'assets', 'Tổng tài sản ngắn hạn',         6,  'total',  607),
(2025, 'assets', 'TÀI SẢN DÀI HẠN',             7,  'bold',   NULL),
(2025, 'assets', 'Tài sản cố định',               8,  'normal', 234),
(2025, 'assets', 'Đầu tư tài chính dài hạn',      9,  'normal', 88),
(2025, 'assets', 'Tài sản dài hạn khác',          10, 'normal', 54),
(2025, 'assets', 'Tổng tài sản dài hạn',          11, 'total',  376),
(2025, 'assets', 'TỔNG TÀI SẢN',                 12, 'total',  983),
(2025, 'liabilities', 'NỢ NGẮN HẠN',             1,  'bold',   NULL),
(2025, 'liabilities', 'Vay ngắn hạn',             2,  'normal', 145),
(2025, 'liabilities', 'Phải trả người bán',        3,  'normal', 98),
(2025, 'liabilities', 'Nợ ngắn hạn khác',         4,  'normal', 67),
(2025, 'liabilities', 'Tổng nợ ngắn hạn',         5,  'total',  310),
(2025, 'liabilities', 'NỢ DÀI HẠN',              6,  'bold',   NULL),
(2025, 'liabilities', 'Vay dài hạn',              7,  'normal', 188),
(2025, 'liabilities', 'Nợ dài hạn khác',          8,  'normal', 32),
(2025, 'liabilities', 'Tổng nợ dài hạn',          9,  'total',  220),
(2025, 'liabilities', 'TỔNG NỢ PHẢI TRẢ',        10, 'total',  530),
(2025, 'equity', 'Vốn điều lệ',                   1,  'normal', 300),
(2025, 'equity', 'Thặng dư vốn cổ phần',          2,  'normal', 65),
(2025, 'equity', 'Lợi nhuận chưa phân phối',      3,  'normal', 88),
(2025, 'equity', 'TỔNG VỐN CHỦ SỞ HỮU',         4,  'total',  453),
(2025, 'equity', 'TỔNG NỢ + VCSH',              5,  'total',  983)
ON CONFLICT (year, section, row_order) DO NOTHING;

-- SEED: Cash Flow 2025
INSERT INTO bod_cashflow (year, section, label, row_order, row_type, value) VALUES
(2025, 'operating', 'Lợi nhuận trước thuế',                    1, 'normal', 178),
(2025, 'operating', 'Khấu hao & phân bổ',                      2, 'normal', 48),
(2025, 'operating', 'Thay đổi vốn lưu động',                   3, 'normal', -42),
(2025, 'operating', 'Thuế TNDN đã nộp',                        4, 'normal', -34),
(2025, 'operating', 'LCT từ hoạt động kinh doanh',             5, 'total',  150),
(2025, 'investing', 'Mua sắm tài sản cố định',                 1, 'normal', -85),
(2025, 'investing', 'Thu từ thanh lý tài sản',                 2, 'normal', 12),
(2025, 'investing', 'Đầu tư tài chính',                        3, 'normal', -30),
(2025, 'investing', 'LCT từ hoạt động đầu tư',                 4, 'total',  -103),
(2025, 'financing', 'Vay mới trong kỳ',                        1, 'normal', 120),
(2025, 'financing', 'Trả nợ vay',                              2, 'normal', -95),
(2025, 'financing', 'Cổ tức đã trả',                           3, 'normal', -28),
(2025, 'financing', 'LCT từ hoạt động tài chính',             4, 'total',  -3),
(2025, 'financing', 'TĂNG/GIẢM TIỀN THUẦN',                  5, 'total',  44),
(2025, 'financing', 'Tiền đầu kỳ',                             6, 'normal', 141),
(2025, 'financing', 'Tiền cuối kỳ',                            7, 'total',  185)
ON CONFLICT (year, section, row_order) DO NOTHING;

-- SEED: Monthly Revenue 2026
INSERT INTO bod_monthly_revenue (year, month, segment, revenue, budget) VALUES
(2026, 1, 'primary',   38, 42), (2026, 1, 'branded', 25, 28), (2026, 1, 'secondary', 15, 16), (2026, 1, 'service', 0, 5),
(2026, 2, 'primary',   30, 42), (2026, 2, 'branded', 22, 28), (2026, 2, 'secondary', 12, 16), (2026, 2, 'service', 0, 5),
(2026, 3, 'primary',   45, 48), (2026, 3, 'branded', 32, 30), (2026, 3, 'secondary', 14, 18), (2026, 3, 'service', 0, 5),
(2026, 4, 'primary',   58, 52), (2026, 4, 'branded', 38, 32), (2026, 4, 'secondary', 17, 18), (2026, 4, 'service', 0, 5),
(2026, 5, 'primary',   72, 55), (2026, 5, 'branded', 48, 35), (2026, 5, 'secondary', 18, 20), (2026, 5, 'service', 0, 5),
(2026, 6, 'primary',   14, 55), (2026, 6, 'branded',  9, 35), (2026, 6, 'secondary',  5, 20), (2026, 6, 'service', 0, 5)
ON CONFLICT (year, month, segment) DO NOTHING;

-- SEED: Monthly KPI 2026
INSERT INTO bod_monthly_kpi (year, month, deals_closed, deals_pipeline, conversion_rate, new_customers, active_customers, avg_deal_size) VALUES
(2026, 1, 12, 45, 26.7, 38, 142, 6.5),
(2026, 2, 9,  38, 23.7, 28, 134, 7.1),
(2026, 3, 15, 52, 28.8, 44, 158, 6.1),
(2026, 4, 19, 61, 31.1, 52, 171, 5.9),
(2026, 5, 23, 68, 33.8, 61, 188, 6.0),
(2026, 6, 5,  72, 6.9,  18, 195, 5.6)
ON CONFLICT (year, month) DO NOTHING;

-- SEED: Project Revenue 2026
INSERT INTO bod_project_revenue (year, month, project_name, segment, revenue) VALUES
(2026, 5, 'Dự án Alpha',  'primary',   28),
(2026, 5, 'Dự án Beta',   'primary',   22),
(2026, 5, 'Dự án Gamma',  'primary',   22),
(2026, 5, 'Dự án Delta',  'branded',   30),
(2026, 5, 'Dự án Epsilon','branded',   18),
(2026, 5, 'Dự án Zeta',   'secondary', 18)
ON CONFLICT (year, month, project_name) DO NOTHING;
