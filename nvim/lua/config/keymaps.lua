local keymap = vim.keymap
local opts = { noremap = true, silent = true }  -- 노리맵(no recursive mapping)과 무음(silent) 옵션 설정

keymap.set("n", "x", '"_x')  -- x 키로 문자 삭제 시, 삭제한 내용을 무시 레지스터로 보내어 클립보드를 덮어쓰지 않음

-- Increment/decrement
keymap.set("n", "+", "<C-a>")  -- + 키로 숫자 증가
keymap.set("n", "-", "<C-x>")  -- - 키로 숫자 감소

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")  -- Ctrl + a로 전체 선택

-- Save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)  -- 리더 키 + w로 파일 저장
keymap.set("n", "<Leader>q", ":quit<Return>", opts)    -- 리더 키 + q로 파일 종료
keymap.set("n", "<Leader>Q", ":qa<Return>", opts)      -- 리더 키 + Q로 모든 파일 종료

-- File explorer with NvimTree
keymap.set("n", "<Leader>f", ":NvimTreeFindFile<Return>", opts)  -- 리더 키 + f로 현재 파일을 NvimTree에서 탐색
keymap.set("n", "<Leader>t", ":NvimTreeToggle<Return>", opts)    -- 리더 키 + t로 NvimTree 토글

-- Tabs
keymap.set("n", "te", ":tabedit")  -- te로 새 탭 열기
keymap.set("n", "<tab>", ":tabnext<Return>", opts)  -- 탭 키로 다음 탭으로 이동
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)  -- Shift + 탭 키로 이전 탭으로 이동
keymap.set("n", "tw", ":tabclose<Return>", opts)  -- tw로 현재 탭 닫기

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)  -- ss로 수평 분할
keymap.set("n", "sv", ":vsplit<Return>", opts)  -- sv로 수직 분할

-- Move window
keymap.set("n", "sh", "<C-w>h")  -- sh로 왼쪽 창으로 이동
keymap.set("n", "sk", "<C-w>k")  -- sk로 위쪽 창으로 이동
keymap.set("n", "sj", "<C-w>j")  -- sj로 아래쪽 창으로 이동
keymap.set("n", "sl", "<C-w>l")  -- sl로 오른쪽 창으로 이동

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><")  -- Ctrl + Shift + h로 창을 왼쪽으로 확장
keymap.set("n", "<C-S-l>", "<C-w>>")  -- Ctrl + Shift + l로 창을 오른쪽으로 확장
keymap.set("n", "<C-S-k>", "<C-w>+")  -- Ctrl + Shift + k로 창을 위쪽으로 확장
keymap.set("n", "<C-S-j>", "<C-w>-")  -- Ctrl + Shift + j로 창을 아래쪽으로 확장

-- Diagnostics
keymap.set("n", "<C-j>", function()    -- Ctrl + j로 다음 진단 메시지로 이동
  vim.diagnostic.goto_next()
end, opts)