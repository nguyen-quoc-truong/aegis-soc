\# Contributing Guidelines



This document describes how our group works on the AEGIS course project.

All members should read it before making changes to the repository.



\## 1. Git Workflow



1\. Update your local `main` before starting:

&#x20;  ```

&#x20;  git checkout main

&#x20;  git pull

&#x20;  ```

2\. Create a new branch for your task:

&#x20;  ```

&#x20;  git checkout -b feature/<task-name>

&#x20;  ```

3\. Commit your work in small steps.

4\. Push the branch and open a Pull Request (PR) on GitHub.

5\. Ask at least one group member to review the PR.

6\. Merge with \*\*Squash and merge\*\*, then delete the branch.



Do not push directly to `main`.



\## 2. Branch Names



Use `<type>/<short-description>`, lowercase, words separated by hyphens.



| Type | Purpose | Example |

|---|---|---|

| `feature/` | New hardware, firmware or application feature | `feature/pwm-gen` |

| `fix/` | Bug fix | `fix/spi-timing` |

| `docs/` | Documentation and report material | `docs/register-map` |

| `test/` | Testbench only | `test/fifo-corner-cases` |

| `chore/` | Repository setup, configuration | `chore/repo-standards` |



\## 3. Commit Messages



We follow the \[Conventional Commits](https://www.conventionalcommits.org/) format:



```

<type>(<scope>): <short summary>

```



\- Write in English, imperative mood (`add`, `fix`, `update`), lowercase, no period at the end.

\- Keep the summary under 50 characters.

\- Types: `feat`, `fix`, `test`, `docs`, `refactor`, `build`, `chore`.

\- Scopes: `adc`, `avg`, `fifo`, `pwm`, `fault`, `top`, `qsys`, `fw`, `app`, `docs`.



Examples:



```

feat(adc): add LTC2308 SPI controller

fix(pwm): latch duty at period start

test(fifo): add full and empty test cases

docs: add register map

```



\## 4. Verilog Guidelines



\- One module per file. The file name matches the module name.

\- Input ports start with `i`, output ports start with `o` (`iClk`, `oPwm`).

\- Active-low signals end with `\_n` (`iReset\_n`).

\- Use one clock (50 MHz). Do not create new clocks with counters; use enable signals instead.

\- Reset is asynchronous and active-low: `always @(posedge iClk, negedge iReset\_n)`.

\- Use `<=` in sequential blocks and `=` in combinational blocks.

\- Use `parameter` or `localparam` instead of fixed numbers.

\- Start each file with a short header comment: project, module name, description.



\## 5. Simulation



\- Each RTL module has a testbench `sim/tb\_<module>.v` and a script `sim/run\_<module>.do`.

\- Testbenches check results automatically and print `PASS` or `FAIL` for each test case.

\- A module is complete only when all test cases pass.

\- Save important waveform screenshots in `docs/sim/` for the report.



\## 6. C Firmware Guidelines



\- Put spaces only around `+` and `-`. Do not put spaces around `\*`, `/`, `=`, `==`, `<`, `>`.

\- Always use braces `{}` for `if`, `else`, `for` and `while`, even for one line.

\- Use the macros in `aegis\_daq\_ctrl\_regs.h` instead of raw register offsets.

\- Write comments and names in English.



\## 7. Files Changed by Tools



Quartus and Eclipse modify some files automatically. Before committing, run `git status`. If one of these files is listed and you did not change it on purpose, discard the change:



| File | Changed by |

|---|---|

| `hw/quartus/aegis\_top.qsf` | Quartus |

| `hw/quartus/software/aegis\_app/Makefile` | Eclipse |

| `hw/quartus/software/aegis\_app\_bsp/settings.bsp` | Eclipse |



```

git checkout -- <file>

```



\## 8. Shared Project Files



Only the member in charge of system integration edits these files, to avoid merge conflicts:



\- `hw/quartus/aegis\_system.qsys`

\- `hw/quartus/aegis\_top.qsf`



If you need a change in these files, open an issue and assign it to that member.



\## 9. Before Opening a Pull Request



\- \[ ] Your branch is based on the latest `main`

\- \[ ] Simulation passes (write the result in the PR, e.g. `9 PASS, 0 FAIL`)

\- \[ ] Waveform screenshots are attached for new modules

\- \[ ] `docs/` is updated if registers or interfaces changed

\- \[ ] `CHANGELOG.md` is updated under `\[Unreleased]`

