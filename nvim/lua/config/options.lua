vim.g.mapleader = " " -- 리더 키를 공백으로 설정 (매핑에서 리더 키로 사용됨)

vim.scriptencoding = "utf-8" -- Vim 스크립트의 인코딩을 UTF-8로 설정
vim.opt.fileencoding = "utf-8" -- 파일을 저장할 때 사용하는 인코딩을 UTF-8로 설정

vim.opt.number = true -- 줄 번호를 표시

vim.opt.title = true -- 편집기 제목을 활성화 (현재 편집 중인 파일 이름을 표시)
vim.opt.hlsearch = true -- 검색 결과를 강조 표시
vim.opt.backup = false -- 파일 백업 기능을 비활성화
vim.opt.cmdheight = 0 -- 명령어 입력 라인의 높이를 0으로 설정 (상태 라인에 합침)
vim.opt.laststatus = 0 -- 마지막 상태 라인을 숨김
vim.opt.scrolloff = 10 -- 커서가 화면 가장자리에 가까워질 때 스크롤 오프셋 설정
vim.opt.inccommand = "split" -- 실시간으로 명령 결과를 스플릿 창에 보여줌
vim.opt.smarttab = true -- 스마트 탭을 활성화 (들여쓰기 시 탭 설정 자동 적용)
vim.opt.breakindent = true -- 줄이 길어질 경우 들여쓰기를 유지한 채로 줄 바꿈
vim.opt.shiftwidth = 2 -- 자동 들여쓰기에서 사용할 공백 수 설정
vim.opt.tabstop = 2 -- 탭 문자의 너비를 2칸으로 설정
vim.opt.wrap = false -- 줄 바꿈을 비활성화 (한 줄에 모든 내용을 표시)
vim.opt.backspace = { "start", "eol", "indent" } -- 백스페이스로 들여쓰기, 줄 끝, 줄 시작 제거 가능
vim.opt.path:append({ "**" }) -- `:find` 명령에서 하위 디렉토리까지 검색 경로 추가
vim.opt.wildignore:append({ "*/node_modules/*" }) -- 파일 탐색에서 node_modules 폴더 무시
vim.opt.splitbelow = true -- 새로운 수평 분할 창을 아래쪽에 생성
vim.opt.splitright = true -- 새로운 수직 분할 창을 오른쪽에 생성
vim.opt.splitkeep = "cursor" -- 분할 시 커서 위치 유지
vim.opt.mouse = "" -- 마우스 기능 비활성화

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" }) -- 블록 주석에서 자동으로 별표 추가
