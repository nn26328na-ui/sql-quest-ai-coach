const SQL_WASM_URL = "https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.10.3/";
const STORAGE_KEY = "sqlQuestAiCoach.v1";

const state = {
  db: null,
  challenges: [],
  chapters: [],
  currentIndex: 0,
  hintLevel: 0,
  progress: {
    done: {},
    xp: 0,
    streak: 0,
    badcases: [],
    config: {
      endpoint: "https://api.deepseek.com/chat/completions",
      model: "deepseek-v4-flash",
      apiKey: ""
    }
  }
};

const el = {};

document.addEventListener("DOMContentLoaded", () => {
  bindElements();
  bindEvents();
  loadProgress();
  hydrateConfig();
  boot();
});

function bindElements() {
  [
    "exportEvidenceBtn", "resetBtn", "progressLabel", "progressBar", "xpStat", "streakStat",
    "badcaseStat", "chapterFilter", "challengeList", "chapterBadge", "challengeTitle",
    "difficultyPips", "promptText", "microGoal", "schemaBtn", "hintBtn", "answerBtn",
    "interviewBtn", "sqlEditor", "runBtn", "nextBtn", "runtimeState", "resultBox",
    "coachConfigBtn", "coachConfig", "apiEndpoint", "apiModel", "apiKey", "saveConfigBtn",
    "aiHintBtn", "aiReviewBtn", "coachOutput", "scoreCorrectness", "scoreGrain",
    "scoreDefense", "badcaseList"
  ].forEach((id) => {
    el[id] = document.getElementById(id);
  });
}

function bindEvents() {
  el.runBtn.addEventListener("click", runUserSql);
  el.nextBtn.addEventListener("click", () => moveChallenge(1));
  el.schemaBtn.addEventListener("click", showSchema);
  el.hintBtn.addEventListener("click", showHint);
  el.answerBtn.addEventListener("click", showAnswer);
  el.interviewBtn.addEventListener("click", showInterviewQuestion);
  el.chapterFilter.addEventListener("change", renderChallengeList);
  el.coachConfigBtn.addEventListener("click", () => el.coachConfig.classList.toggle("open"));
  el.saveConfigBtn.addEventListener("click", saveConfig);
  el.aiHintBtn.addEventListener("click", () => askCoach("hint"));
  el.aiReviewBtn.addEventListener("click", () => askCoach("review"));
  el.exportEvidenceBtn.addEventListener("click", exportEvidence);
  el.resetBtn.addEventListener("click", resetProgress);
}

async function boot() {
  try {
    el.runtimeState.textContent = "加载 SQL 引擎";
    const SQL = await initSqlJs({ locateFile: (file) => SQL_WASM_URL + file });
    const sqlText = await fetch("./assets/advanced_sql_interview_challenge_pack.sql").then((r) => r.text());
    state.db = new SQL.Database();
    state.db.run(sqlText);
    loadDataFromDb();
    renderFilters();
    showChallenge(0);
    el.runtimeState.textContent = "浏览器 SQLite 已就绪";
  } catch (error) {
    el.runtimeState.textContent = "初始化失败";
    writeResult("初始化失败：\n" + error.message, false);
  }
}

function loadDataFromDb() {
  state.chapters = rowsOf("SELECT chapter_id, title, focus FROM chapters ORDER BY order_index");
  state.challenges = rowsOf(`
    SELECT c.challenge_id, c.chapter_id, ch.title AS chapter_title, c.slug, c.title,
           c.difficulty, c.interview_signal, c.prompt, c.schema_focus, c.starter_sql,
           c.expected_query, c.check_mode, c.hint_1, c.hint_2, c.explanation,
           c.estimated_minutes, c.xp
    FROM challenges c
    JOIN chapters ch ON ch.chapter_id = c.chapter_id
    ORDER BY c.challenge_id
  `);
}

function rowsOf(sql) {
  const result = state.db.exec(sql)[0];
  if (!result) return [];
  return result.values.map((row) => {
    const record = {};
    result.columns.forEach((column, index) => {
      record[column] = row[index];
    });
    return record;
  });
}

function renderFilters() {
  el.chapterFilter.innerHTML = `<option value="all">全部章节</option>` + state.chapters
    .map((chapter) => `<option value="${chapter.chapter_id}">${escapeHtml(chapter.title)}</option>`)
    .join("");
}

function renderChallengeList() {
  const selected = el.chapterFilter.value;
  const items = state.challenges
    .map((challenge, index) => ({ challenge, index }))
    .filter((item) => selected === "all" || String(item.challenge.chapter_id) === selected);

  el.challengeList.innerHTML = items.map(({ challenge, index }) => {
    const active = index === state.currentIndex ? " active" : "";
    const done = state.progress.done[challenge.challenge_id] ? " done" : "";
    return `
      <button class="challenge-item${active}${done}" data-index="${index}" type="button">
        <strong>${challenge.challenge_id}. ${escapeHtml(challenge.title)}</strong>
        <small>难度 ${challenge.difficulty}/5 · ${escapeHtml(challenge.schema_focus)}</small>
      </button>
    `;
  }).join("");

  [...el.challengeList.querySelectorAll(".challenge-item")].forEach((button) => {
    button.addEventListener("click", () => showChallenge(Number(button.dataset.index)));
  });
}

function showChallenge(index) {
  state.currentIndex = clamp(index, 0, state.challenges.length - 1);
  state.hintLevel = 0;
  const challenge = currentChallenge();
  if (!challenge) return;

  el.chapterBadge.textContent = challenge.chapter_title;
  el.challengeTitle.textContent = `${challenge.challenge_id}. ${challenge.title}`;
  el.promptText.textContent = challenge.prompt;
  el.microGoal.textContent = microGoalFor(challenge);
  el.sqlEditor.value = challenge.starter_sql || "SELECT ";
  el.hintBtn.textContent = "提示 1";
  el.resultBox.textContent = "";
  el.resultBox.className = "result-box";
  renderDifficulty(challenge.difficulty);
  renderChallengeList();
  renderProgress();
  renderBadcases();
  setRubric("-", "-", "-");
}

function renderDifficulty(difficulty) {
  el.difficultyPips.innerHTML = "";
  for (let index = 1; index <= 5; index++) {
    const pip = document.createElement("span");
    pip.className = index <= difficulty ? "pip on" : "pip";
    el.difficultyPips.appendChild(pip);
  }
}

function renderProgress() {
  const doneCount = Object.keys(state.progress.done).length;
  el.progressLabel.textContent = `${doneCount} / ${state.challenges.length}`;
  el.progressBar.style.width = `${Math.round(100 * doneCount / Math.max(1, state.challenges.length))}%`;
  el.xpStat.textContent = String(state.progress.xp);
  el.streakStat.textContent = String(state.progress.streak);
  el.badcaseStat.textContent = String(state.progress.badcases.length);
}

function renderBadcases() {
  const cases = state.progress.badcases.slice(-4).reverse();
  if (cases.length === 0) {
    el.badcaseList.textContent = "还没有失败样本。失败不是惩罚，是你的训练数据。";
    return;
  }
  el.badcaseList.textContent = cases.map((item) =>
    `#${item.challengeId} ${item.title}\n低分维度：${item.failureType}\n下一步：${item.nextAction}`
  ).join("\n\n");
}

function runUserSql() {
  const challenge = currentChallenge();
  const userSql = el.sqlEditor.value.trim();
  if (!userSql) {
    writeResult("先写一行 SQL。启动比完美更重要。", false);
    return;
  }

  if (challenge.check_mode === "manual_review") {
    writeResult("这关是工程解释题，不做自动判题。\n\n参考答案：\n" + challenge.expected_query, true);
    markDone(challenge);
    return;
  }

  if (!isReadOnlyQuery(userSql)) {
    writeResult("为了保护题库，网页闯关只允许 SELECT 或 WITH 查询。", false);
    addBadcase(challenge, "安全边界", "把答案改成只读查询，再运行。");
    return;
  }

  try {
    const actual = queryResult(userSql);
    const expected = queryResult(challenge.expected_query);
    if (sameResult(actual, expected)) {
      writeResult("通过。\n\n你的结果：\n" + previewResult(actual), true);
      markDone(challenge);
      setRubric("5", "5", "待追问");
      el.coachOutput.textContent = localCoachPass(challenge);
    } else {
      const failureType = classifyFailure(actual, expected, null);
      writeResult(
        "结果还不一致。\n\n你的结果：\n" + previewResult(actual) +
        "\n\n期望结果：\n" + previewResult(expected) +
        "\n\n诊断：" + failureType,
        false
      );
      state.progress.streak = 0;
      addBadcase(challenge, failureType, nextActionFor(failureType));
      setRubric("2", failureType.includes("粒度") ? "1" : "3", "待复盘");
      el.coachOutput.textContent = localCoachFail(challenge, failureType);
      saveProgress();
      renderProgress();
    }
  } catch (error) {
    const failureType = classifyFailure(null, null, error);
    writeResult("SQL 执行失败：\n" + error.message + "\n\n诊断：" + failureType, false);
    state.progress.streak = 0;
    addBadcase(challenge, failureType, nextActionFor(failureType));
    setRubric("1", "待查", "待复盘");
    el.coachOutput.textContent = localCoachFail(challenge, failureType);
    saveProgress();
    renderProgress();
  }
}

function queryResult(sql) {
  const results = state.db.exec(sql);
  const result = results[results.length - 1];
  if (!result) return { columns: [], values: [] };
  return result;
}

function sameResult(left, right) {
  if (left.columns.length !== right.columns.length || left.values.length !== right.values.length) {
    return false;
  }
  for (let row = 0; row < left.values.length; row++) {
    for (let column = 0; column < left.columns.length; column++) {
      if (normalizeCell(left.values[row][column]) !== normalizeCell(right.values[row][column])) {
        return false;
      }
    }
  }
  return true;
}

function previewResult(result) {
  if (!result.columns.length) return "Rows: 0";
  const lines = [];
  lines.push(result.columns.join(" | "));
  lines.push("-".repeat(Math.min(92, Math.max(6, lines[0].length))));
  result.values.slice(0, 12).forEach((row) => lines.push(row.map(formatCell).join(" | ")));
  if (result.values.length > 12) lines.push(`... ${result.values.length - 12} more rows`);
  lines.push(`Rows: ${result.values.length}`);
  return lines.join("\n");
}

function showSchema() {
  const challenge = currentChallenge();
  const tables = challenge.schema_focus.split(",").map((name) => name.trim()).filter(Boolean);
  const output = tables.map((table) => {
    const rows = rowsOf(`PRAGMA table_info(${safeIdentifier(table)})`);
    return table + "\n" + rows.map((row) => `  ${row.name} ${row.type}`).join("\n");
  }).join("\n\n");
  writeResult(output, true);
}

function showHint() {
  const challenge = currentChallenge();
  state.hintLevel += 1;
  if (state.hintLevel === 1) {
    writeResult("提示 1：\n" + challenge.hint_1, true);
    el.hintBtn.textContent = "提示 2";
  } else {
    writeResult("提示 2：\n" + challenge.hint_2, true);
  }
}

function showAnswer() {
  const challenge = currentChallenge();
  writeResult("参考答案：\n\n" + challenge.expected_query + "\n\n复盘：\n" + challenge.explanation, true);
}

function showInterviewQuestion() {
  const challenge = currentChallenge();
  const question = `面试官可能追问：\n你为什么先处理「${challenge.schema_focus}」的结果粒度，而不是直接 JOIN 后开窗或聚合？如果数据量扩大 100 倍，你会先检查哪两个执行风险？`;
  el.coachOutput.textContent = question;
}

function markDone(challenge) {
  const firstPass = !state.progress.done[challenge.challenge_id];
  state.progress.done[challenge.challenge_id] = true;
  if (firstPass) state.progress.xp += Number(challenge.xp || 30);
  state.progress.streak += 1;
  saveProgress();
  renderProgress();
  renderChallengeList();
}

function addBadcase(challenge, failureType, nextAction) {
  state.progress.badcases.push({
    at: new Date().toISOString(),
    challengeId: challenge.challenge_id,
    title: challenge.title,
    slug: challenge.slug,
    failureType,
    nextAction,
    sql: el.sqlEditor.value.slice(0, 2000)
  });
  state.progress.badcases = state.progress.badcases.slice(-30);
  saveProgress();
  renderBadcases();
}

function classifyFailure(actual, expected, error) {
  if (error) {
    const message = String(error.message || error).toLowerCase();
    if (message.includes("syntax")) return "语法错误";
    if (message.includes("no such table") || message.includes("no such column")) return "表结构或字段理解错误";
    return "SQL 执行错误";
  }
  if (actual.values.length !== expected.values.length) return "结果粒度或过滤条件错误";
  if (actual.columns.length !== expected.columns.length) return "返回列数量不一致";
  return "值不一致，优先检查 JOIN、排序、窗口分区或业务口径";
}

function nextActionFor(failureType) {
  if (failureType.includes("粒度")) return "先写 CTE，把结果压到题目要求的业务粒度。";
  if (failureType.includes("字段")) return "点“查看表结构”，确认列名和表名。";
  if (failureType.includes("语法")) return "先跑最小 SELECT，再逐段加 CTE。";
  if (failureType.includes("列数量")) return "对照题面，只返回要求的列。";
  return "检查 JOIN 是否放大行数，再检查窗口 PARTITION/ORDER。";
}

function localCoachPass(challenge) {
  return `这关过了。别急着下一题，先用 20 秒说清楚：\n1. 这题的结果粒度是什么？\n2. 哪个 CTE 是为了控粒度？\n3. 面试官追问“为什么不用简单 GROUP BY”时，你怎么答？\n\n本题复盘：${challenge.explanation}`;
}

function localCoachFail(challenge, failureType) {
  return `先别看答案。你这次更像卡在：${failureType}。\n\n建议只做一个小动作：${nextActionFor(failureType)}\n\n不剧透提示：${challenge.hint_1}`;
}

async function askCoach(mode) {
  const challenge = currentChallenge();
  const userSql = el.sqlEditor.value.trim();
  const lastBadcase = state.progress.badcases[state.progress.badcases.length - 1];

  if (!state.progress.config.apiKey) {
    el.coachOutput.textContent = mode === "hint"
      ? localCoachFail(challenge, "待诊断")
      : "还没配置 API Key，先用本地复盘：\n" + (lastBadcase ? `${lastBadcase.failureType}\n${lastBadcase.nextAction}` : challenge.explanation);
    return;
  }

  el.coachOutput.textContent = "AI Coach 思考中...";
  try {
    const prompt = buildCoachPrompt(mode, challenge, userSql, lastBadcase);
    const response = await fetch(state.progress.config.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${state.progress.config.apiKey}`
      },
      body: JSON.stringify({
        model: state.progress.config.model,
        messages: [
          {
            role: "system",
            content: "你是高级 SQL 面试教练。不要直接泄露答案，除非用户明确要求答案。用中文，短句，先诊断卡点，再给一个下一步动作。"
          },
          { role: "user", content: prompt }
        ],
        temperature: 0.4
      })
    });
    if (!response.ok) throw new Error(`API ${response.status}: ${await response.text()}`);
    const data = await response.json();
    el.coachOutput.textContent = data.choices?.[0]?.message?.content || "AI 没有返回内容。";
  } catch (error) {
    el.coachOutput.textContent = "AI 调用失败，已切回本地教练：\n" + error.message + "\n\n" + localCoachFail(challenge, "AI 调用失败");
  }
}

function buildCoachPrompt(mode, challenge, userSql, lastBadcase) {
  return `
模式：${mode}
题目：${challenge.title}
题面：${challenge.prompt}
聚焦表：${challenge.schema_focus}
面试信号：${challenge.interview_signal}
用户 SQL：
${userSql || "(空)"}
最近 badcase：
${lastBadcase ? JSON.stringify(lastBadcase, null, 2) : "(无)"}

请输出：
1. 判断用户最可能卡在哪个链路节点：表结构 / 结果粒度 / JOIN 放大 / 窗口函数 / 业务口径 / 性能解释
2. 给一个不剧透的提示
3. 给一个 60 秒内能做的小动作
4. 如果是 review 模式，再给一个面试追问
`;
}

function exportEvidence() {
  const payload = {
    project: "SQL Quest AI Coach",
    exportedAt: new Date().toISOString(),
    progress: state.progress,
    gateSummary: {
      scenario: "高级 SQL 面试训练者在刷题卡住或复盘时，需要 AI 诊断错误链路并生成面试追问。",
      aiNeed: "自然语言题面、SQL 错误、业务口径解释具有模糊性，规则只能判对错，AI 适合做诊断和追问。",
      evalLoop: "每次运行形成 case，失败样本进入 badcase log，用 failureType 和 nextAction 驱动复盘。"
    }
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "sql-quest-ai-evidence.json";
  link.click();
  URL.revokeObjectURL(url);
}

function resetProgress() {
  if (!confirm("确定重置本机进度？题库不会被删除。")) return;
  localStorage.removeItem(STORAGE_KEY);
  state.progress = { done: {}, xp: 0, streak: 0, badcases: [], config: state.progress.config };
  saveProgress();
  showChallenge(state.currentIndex);
}

function saveConfig() {
  state.progress.config.endpoint = el.apiEndpoint.value.trim();
  state.progress.config.model = el.apiModel.value.trim();
  state.progress.config.apiKey = el.apiKey.value.trim();
  saveProgress();
  el.coachConfig.classList.remove("open");
  el.coachOutput.textContent = "AI 设置已保存到本机 localStorage。不要把 API Key 提交到 GitHub。";
}

function hydrateConfig() {
  el.apiEndpoint.value = state.progress.config.endpoint;
  el.apiModel.value = state.progress.config.model;
  el.apiKey.value = state.progress.config.apiKey;
}

function loadProgress() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
    state.progress = {
      done: saved.done || {},
      xp: saved.xp || 0,
      streak: saved.streak || 0,
      badcases: saved.badcases || [],
      config: {
        endpoint: saved.config?.endpoint || state.progress.config.endpoint,
        model: saved.config?.model || state.progress.config.model,
        apiKey: saved.config?.apiKey || ""
      }
    };
  } catch {
    saveProgress();
  }
}

function saveProgress() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.progress));
}

function moveChallenge(delta) {
  showChallenge(state.currentIndex + delta);
}

function currentChallenge() {
  return state.challenges[state.currentIndex];
}

function writeResult(text, pass) {
  el.resultBox.textContent = text;
  el.resultBox.className = pass ? "result-box pass" : "result-box fail";
}

function setRubric(correctness, grain, defense) {
  el.scoreCorrectness.textContent = correctness;
  el.scoreGrain.textContent = grain;
  el.scoreDefense.textContent = defense;
}

function microGoalFor(challenge) {
  if (challenge.slug.includes("cohort")) return "先定义 cohort 月，再算相对月份。";
  if (challenge.slug.includes("join") || challenge.slug.includes("reconciliation")) return "先分别聚合，再 JOIN，避免行数放大。";
  if (challenge.slug.includes("recursive")) return "先写 anchor，再写 recursive step。";
  if (challenge.slug.includes("index")) return "先说查询路径，再决定索引列顺序。";
  if (challenge.slug.includes("funnel")) return "先压到用户或 session 粒度，再算转化。";
  return "先判断结果粒度，再写 SQL。";
}

function isReadOnlyQuery(sql) {
  const cleaned = sql.trim().replace(/^--.*$/gm, "").trim().toLowerCase();
  return cleaned.startsWith("select") || cleaned.startsWith("with");
}

function safeIdentifier(name) {
  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(name)) throw new Error("Invalid table name");
  return name;
}

function normalizeCell(value) {
  if (value === null || value === undefined) return "NULL";
  const number = Number(value);
  if (!Number.isNaN(number) && String(value).trim() !== "") return number.toFixed(6);
  return String(value).trim();
}

function formatCell(value) {
  if (value === null || value === undefined) return "NULL";
  return String(value);
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
