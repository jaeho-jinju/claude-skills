# claude-skills

개인 Claude Code 스킬 모음.

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `my-slides` | 다크 테마 HTML 발표자료 자동 생성 (`/my-slides`) |

## 설치

```bash
git clone git@github.com:jaeho-jinju/claude-skills.git
cd claude-skills
chmod +x install.sh
./install.sh
```

`~/.claude/skills/` 안에 각 스킬 폴더가 심볼릭 링크로 연결된다.

## 업데이트

```bash
cd claude-skills
git pull
```

`git pull` 만으로 심볼릭 링크를 통해 즉시 반영된다. install 재실행 불필요.

## 새 스킬 추가

루트에 스킬 폴더를 추가하면 된다.
`SKILL.md`가 있는 폴더만 `install.sh`가 인식한다.

```
claude-skills/
├── my-slides/
│   ├── SKILL.md
│   └── assets/
├── new-skill/          ← 새 스킬 추가
│   └── SKILL.md
├── install.sh
└── README.md
```
