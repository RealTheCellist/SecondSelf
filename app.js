const STORAGE_KEY = "second-self-checkins-v1";
const EVENT_STORAGE_KEY = "second-self-events-v1";

const prompts = [
  { id: "thought", label: "요즘 자주 붙잡히는 생각은 무엇인가요?" },
  { id: "emotion", label: "최근 반복해서 느끼는 감정은 무엇인가요?" },
  { id: "identity", label: "지금의 나를 한 문장으로 표현하면 어떤가요?" },
];

const emotionOptions = ["불안", "압박감", "기대", "자신감", "혼란", "안정감", "의욕", "무기력"];

const keywordMap = [
  { keyword: "일", triggers: ["일", "회사", "업무", "직장", "프로젝트", "성과"] },
  { keyword: "방향성", triggers: ["방향", "진로", "앞으로", "커리어", "선택", "전환"] },
  { keyword: "관계", triggers: ["관계", "사람", "대화", "팀", "가족", "친구"] },
  { keyword: "불확실성", triggers: ["불확실", "모르", "애매", "걱정", "확신"] },
  { keyword: "정리", triggers: ["정리", "정돈", "정돈하다", "정리하다", "정돈감"] },
  { keyword: "휴식", triggers: ["쉬", "휴식", "피곤", "지침", "지쳤"] },
  { keyword: "회복", triggers: ["회복", "버티", "괜찮아지", "진정", "회복감"] },
  { keyword: "압박", triggers: ["압박", "부담", "마감", "빨리", "쫓기"] },
];

const reflectionTemplates = [
  {
    check: (keywords, emotions) => keywords.includes("방향성") && emotions.includes("불안"),
    line: "요즘 당신은 결과보다 방향을 더 오래 붙잡고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("관계") && emotions.includes("혼란"),
    line: "최근의 당신은 관계 속 거리감과 해석 사이에서 오래 머무르고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("정리"),
    line: "지금의 당신은 확신보다 정돈에 더 에너지를 쓰고 있습니다.",
  },
  {
    check: (_keywords, emotions) => emotions.includes("압박감"),
    line: "최근의 당신은 해야 할 것들의 무게를 오래 안고 움직이고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("휴식") && emotions.includes("무기력"),
    line: "지금의 당신은 더 달리기보다 먼저 회복의 여지를 찾고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("일") && emotions.includes("기대"),
    line: "최근의 당신은 부담 속에서도 다음 기회를 함께 바라보고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("관계") && emotions.includes("불안"),
    line: "요즘 당신은 관계의 거리와 마음의 안전함을 함께 살피고 있습니다.",
  },
  {
    check: (keywords, emotions) => keywords.includes("회복") || keywords.includes("휴식"),
    line: "최근의 당신은 버티는 것보다 회복하는 방식에 더 마음이 가고 있습니다.",
  },
];

const state = {
  selectedPromptId: null,
  draftText: "",
  selectedEmotions: [],
  submitAttempted: false,
};

const patternStageLabels = {
  empty: "준비",
  early: "초기",
  preview: "미리보기",
  full: "완성",
};

const sampleCheckins = [
  {
    promptId: "thought",
    promptLabel: "요즘 자주 붙잡히는 생각은 무엇인가요?",
    text: "회사에서 지금 하는 일이 길게 봤을 때 맞는 방향인지 자꾸 확인하게 돼요.",
    emotions: ["불안", "압박감"],
  },
  {
    promptId: "identity",
    promptLabel: "지금의 나를 한 문장으로 표현하면 어떤가요?",
    text: "앞으로 가고는 있는데 확신보다는 점검에 더 가까운 사람 같아요.",
    emotions: ["혼란", "불안"],
  },
  {
    promptId: "emotion",
    promptLabel: "최근 반복해서 느끼는 감정은 무엇인가요?",
    text: "새로운 선택지를 생각하면 기대도 되지만 당장 결정해야 할 것 같아 압박감이 커져요.",
    emotions: ["기대", "압박감"],
  },
  {
    promptId: "thought",
    promptLabel: "요즘 자주 붙잡히는 생각은 무엇인가요?",
    text: "요즘은 성과보다 앞으로 어떤 방향으로 움직일지가 더 크게 보여요.",
    emotions: ["불안", "기대"],
  },
  {
    promptId: "emotion",
    promptLabel: "최근 반복해서 느끼는 감정은 무엇인가요?",
    text: "쉬어야 하는데 멈추면 뒤처질까 봐 압박이 계속 남아 있어요.",
    emotions: ["압박감", "무기력"],
  },
];

const els = {
  screens: {
    question: document.getElementById("screen-question"),
    compose: document.getElementById("screen-compose"),
    reflection: document.getElementById("screen-reflection"),
  },
  questionList: document.getElementById("question-list"),
  questionNext: document.getElementById("question-next"),
  composeBack: document.getElementById("compose-back"),
  selectedPrompt: document.getElementById("selected-prompt"),
  textArea: document.getElementById("checkin-text"),
  textError: document.getElementById("text-error"),
  emotionList: document.getElementById("emotion-list"),
  emotionHint: document.getElementById("emotion-hint"),
  emotionError: document.getElementById("emotion-error"),
  submitError: document.getElementById("submit-error"),
  submitButton: document.getElementById("submit-checkin"),
  reflectionLine: document.getElementById("reflection-line"),
  keywordList: document.getElementById("keyword-list"),
  emptyState: document.getElementById("empty-state"),
  patternCards: document.getElementById("pattern-cards"),
  patternStage: document.getElementById("pattern-stage"),
  topicsCard: document.getElementById("topics-card"),
  emotionsCard: document.getElementById("emotions-card"),
  summaryCard: document.getElementById("summary-card"),
  checkinCount: document.getElementById("checkin-count"),
  topEmotion: document.getElementById("top-emotion"),
  historyList: document.getElementById("history-list"),
  patternSubcopy: document.getElementById("pattern-subcopy"),
  nextCheckin: document.getElementById("next-checkin"),
  resetData: document.getElementById("reset-data"),
  seedData: document.getElementById("seed-data"),
  exportData: document.getElementById("export-data"),
  toast: document.getElementById("toast"),
};

let toastTimer = null;

function init() {
  trackEvent("app_loaded");
  renderQuestions();
  renderEmotionTags();
  bindEvents();
  syncQuestionState();
  syncComposeState();
  renderReflectionFeed();
}

function bindEvents() {
  els.questionNext.addEventListener("click", () => {
    if (!state.selectedPromptId) return;
    const prompt = prompts.find((item) => item.id === state.selectedPromptId);
    els.selectedPrompt.textContent = prompt.label;
    trackEvent("question_continue_clicked", { promptId: prompt.id });
    switchScreen("compose");
    window.setTimeout(() => els.textArea.focus(), 30);
  });

  els.composeBack.addEventListener("click", () => switchScreen("question"));

  els.textArea.addEventListener("input", (event) => {
    state.draftText = event.target.value;
    if (!state.submitAttempted) {
      els.textError.textContent = "";
    }
    els.submitError.textContent = "";
    syncComposeState();
  });

  els.submitButton.addEventListener("click", submitCheckIn);

  els.nextCheckin.addEventListener("click", () => {
    trackEvent("next_checkin_clicked");
    clearDraft();
    resetPromptSelection();
    switchScreen("question");
  });

  els.resetData.addEventListener("click", () => {
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(EVENT_STORAGE_KEY);
    clearDraft();
    resetPromptSelection();
    renderReflectionFeed();
  });

  els.seedData.addEventListener("click", () => {
    seedSampleData();
    renderReflectionFeed();
    switchScreen("reflection");
  });

  els.exportData.addEventListener("click", exportLocalData);
}

function switchScreen(screenName) {
  Object.values(els.screens).forEach((screen) => screen.classList.remove("active"));
  els.screens[screenName].classList.add("active");
}

function renderQuestions() {
  els.questionList.innerHTML = "";

  prompts.forEach((prompt) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "question-card";
    button.setAttribute("role", "radio");
    button.setAttribute("aria-checked", String(state.selectedPromptId === prompt.id));
    button.innerHTML = `
      <span class="question-indicator" aria-hidden="true"></span>
      <span class="question-label">${prompt.label}</span>
    `;

    if (state.selectedPromptId === prompt.id) {
      button.classList.add("selected");
    }

    button.addEventListener("click", () => {
      state.selectedPromptId = prompt.id;
      trackEvent("question_selected", { promptId: prompt.id });
      renderQuestions();
      syncQuestionState();
    });

    els.questionList.appendChild(button);
  });
}

function renderEmotionTags() {
  els.emotionList.innerHTML = "";

  emotionOptions.forEach((emotion) => {
    const chip = document.createElement("button");
    chip.type = "button";
    chip.className = "tag-chip";
    chip.textContent = emotion;

    if (state.selectedEmotions.includes(emotion)) {
      chip.classList.add("selected");
    }

    chip.addEventListener("click", () => toggleEmotion(emotion));
    els.emotionList.appendChild(chip);
  });

  updateEmotionHint();
}

function toggleEmotion(emotion) {
  if (!state.submitAttempted) {
    els.emotionError.textContent = "";
  }
  els.submitError.textContent = "";

  if (state.selectedEmotions.includes(emotion)) {
    state.selectedEmotions = state.selectedEmotions.filter((item) => item !== emotion);
    renderEmotionTags();
    syncComposeState();
    return;
  }

  if (state.selectedEmotions.length >= 2) {
    els.emotionError.textContent = "감정은 2개까지 고를 수 있어요";
    trackEvent("emotion_limit_reached");
    pulseSelectedEmotionTags();
    return;
  }

  state.selectedEmotions = [...state.selectedEmotions, emotion];
  renderEmotionTags();
  syncComposeState();
}

function validateDraft() {
  let valid = true;

  if (!state.draftText.trim()) {
    els.textError.textContent = "한두 문장만 적어도 충분합니다";
    valid = false;
  } else {
    els.textError.textContent = "";
  }

  if (state.selectedEmotions.length === 0) {
    els.emotionError.textContent = "감정 태그를 1개 이상 골라주세요";
    valid = false;
  } else {
    els.emotionError.textContent = "";
  }

  return valid;
}

function submitCheckIn() {
  els.submitError.textContent = "";
  state.submitAttempted = true;

  if (!validateDraft()) {
    syncComposeState();
    return;
  }

  try {
    els.submitButton.textContent = "비추는 중...";
    els.submitButton.disabled = true;
    const checkins = loadCheckins();
    const prompt = prompts.find((item) => item.id === state.selectedPromptId);
    const createdAt = new Date().toISOString();
    const keywords = deriveKeywords(state.draftText, state.selectedEmotions);
    const reflectionLine = buildReflectionLine(keywords, state.selectedEmotions);

    checkins.push({
      id: String(Date.now()),
      promptId: prompt.id,
      promptLabel: prompt.label,
      text: state.draftText.trim(),
      emotions: [...state.selectedEmotions],
      keywords,
      reflectionLine,
      createdAt,
    });

    localStorage.setItem(STORAGE_KEY, JSON.stringify(checkins));
    trackEvent("checkin_submitted", {
      promptId: prompt.id,
      emotionCount: state.selectedEmotions.length,
      keywordCount: keywords.length,
      totalCheckins: checkins.length,
    });
    clearDraft();
    renderReflectionFeed();
    switchScreen("reflection");
  } catch (_error) {
    els.submitError.textContent = "잠시 연결이 불안정해요. 다시 한번 시도해주세요";
  } finally {
    els.submitButton.textContent = "이대로 비춰보기";
    syncComposeState();
  }
}

function clearDraft() {
  state.draftText = "";
  state.selectedEmotions = [];
  state.submitAttempted = false;
  els.textArea.value = "";
  els.textError.textContent = "";
  els.emotionError.textContent = "";
  els.submitError.textContent = "";
  renderEmotionTags();
  syncComposeState();
}

function resetPromptSelection() {
  state.selectedPromptId = null;
  renderQuestions();
  syncQuestionState();
}

function seedSampleData() {
  const seeded = sampleCheckins.map((checkin, index) => {
    const createdAt = new Date(Date.now() - (sampleCheckins.length - index) * 86400000).toISOString();
    const keywords = deriveKeywords(checkin.text, checkin.emotions);
    return {
      id: `sample-${index + 1}`,
      ...checkin,
      keywords,
      reflectionLine: buildReflectionLine(keywords, checkin.emotions),
      createdAt,
    };
  });

  localStorage.setItem(STORAGE_KEY, JSON.stringify(seeded));
  trackEvent("sample_data_seeded", { totalCheckins: seeded.length });
  showToast("샘플 데이터 5개를 채웠어요");
}

function loadCheckins() {
  try {
    const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch (_error) {
    return [];
  }
}

function deriveKeywords(text, emotions) {
  const foundKeywords = [];
  const lowered = text.toLowerCase();
  const normalized = lowered.replace(/[^\p{L}\p{N}\s]/gu, " ");
  const tokens = normalized.split(/\s+/).filter(Boolean);

  keywordMap.forEach((entry) => {
    if (entry.triggers.some((trigger) => lowered.includes(trigger) || tokens.includes(trigger))) {
      foundKeywords.push(entry.keyword);
    }
  });

  if (emotions.includes("불안") && !foundKeywords.includes("불확실성")) {
    foundKeywords.push("불확실성");
  }

  if (foundKeywords.length === 0) {
    foundKeywords.push("정리");
  }

  if ((emotions.includes("무기력") || emotions.includes("안정감")) && !foundKeywords.includes("회복")) {
    foundKeywords.push("회복");
  }

  if (emotions.includes("압박감") && !foundKeywords.includes("압박")) {
    foundKeywords.push("압박");
  }

  return [...new Set(foundKeywords)].slice(0, 2);
}

function buildReflectionLine(keywords, emotions) {
  const match = reflectionTemplates.find((template) => template.check(keywords, emotions));
  if (match) return match.line;

  if (keywords.includes("방향성")) {
    return "최근의 당신은 멈춤보다 다음 방향을 가늠하는 일에 더 오래 머무르고 있습니다.";
  }

  if (emotions.includes("기대")) {
    return "요즘 당신은 불안보다 가능성 쪽으로 마음을 조금 더 기울이고 있습니다.";
  }

  return "지금의 당신은 정리되지 않은 감정과 생각을 한곳에 모아보려 하고 있습니다.";
}

function formatDateLabel(isoString) {
  const date = new Date(isoString);
  return `${date.getMonth() + 1}.${date.getDate()}`;
}

function renderReflectionFeed() {
  const checkins = loadCheckins();
  const recent = [...checkins].slice(-5);
  const latest = recent[recent.length - 1];
  updateInsightStrip(checkins);

  if (!latest) {
    els.reflectionLine.textContent = "오늘의 한 줄부터 시작해볼까요? 짧은 입력 하나면 충분합니다.";
    renderKeywords([]);
    els.emptyState.classList.remove("hidden");
    els.patternCards.classList.add("hidden");
    els.historyList.innerHTML = "";
    setPatternStage("empty");
    els.patternSubcopy.textContent = "체크인이 쌓일수록 반복되는 흐름이 더 선명해집니다";
    els.nextCheckin.textContent = "첫 체크인 시작하기";
    return;
  }

  els.reflectionLine.textContent = latest.reflectionLine;
  renderKeywords(latest.keywords);
  renderHistory(recent);
  trackEvent("reflection_viewed", { totalCheckins: checkins.length });

  if (recent.length < 3) {
    els.emptyState.classList.remove("hidden");
    els.patternCards.classList.add("hidden");
    setPatternStage("early");
    els.patternSubcopy.textContent = "최근 5번의 체크인이 쌓이면 더 선명한 흐름을 보여드릴게요";
    els.nextCheckin.textContent = "다음 체크인 남기기";
    return;
  }

  const summary = buildSummary(recent);
  els.topicsCard.textContent = summary.topTopics.join(", ");
  els.emotionsCard.textContent = summary.topEmotions.join(", ");
  els.summaryCard.textContent = summary.summaryLine;
  els.emptyState.classList.add("hidden");
  els.patternCards.classList.remove("hidden");
  setPatternStage(recent.length < 5 ? "preview" : "full");
  els.patternSubcopy.textContent =
    recent.length < 5
      ? "3회 이상 쌓인 체크인을 기준으로 먼저 보이는 흐름입니다"
      : "최근 5번의 체크인에서 자주 나온 흐름입니다";
  els.nextCheckin.textContent = "다음 체크인 남기기";
}

function renderKeywords(keywords) {
  els.keywordList.innerHTML = "";

  if (keywords.length === 0) {
    ["오늘", "시작"].forEach((keyword) => {
      const chip = document.createElement("span");
      chip.className = "keyword-chip";
      chip.textContent = keyword;
      els.keywordList.appendChild(chip);
    });
    return;
  }

  keywords.forEach((keyword) => {
    const chip = document.createElement("span");
    chip.className = "keyword-chip";
    chip.textContent = keyword;
    els.keywordList.appendChild(chip);
  });
}

function renderHistory(checkins) {
  els.historyList.innerHTML = "";

  checkins
    .slice()
    .reverse()
    .forEach((checkin) => {
      const chip = document.createElement("span");
      chip.className = "history-chip";
      chip.textContent = `${formatDateLabel(checkin.createdAt)} · ${checkin.emotions.join("/")}`;
      els.historyList.appendChild(chip);
    });
}

function syncQuestionState() {
  els.questionNext.disabled = !state.selectedPromptId;
}

function syncComposeState() {
  const hasText = state.draftText.trim().length > 0;
  const hasEmotion = state.selectedEmotions.length > 0;
  els.submitButton.disabled = !(hasText && hasEmotion);

  if (!state.submitAttempted) {
    return;
  }

  els.textError.textContent = hasText ? "" : "한두 문장만 적어도 충분합니다";
  els.emotionError.textContent = hasEmotion ? "" : "감정 태그를 1개 이상 골라주세요";
}

function updateEmotionHint() {
  if (state.selectedEmotions.length === 0) {
    els.emotionHint.textContent = "1개 또는 2개만 선택해도 충분합니다";
    return;
  }

  if (state.selectedEmotions.length === 1) {
    els.emotionHint.textContent = "하나 더 고르거나, 지금 상태로도 충분합니다";
    return;
  }

  els.emotionHint.textContent = "지금은 감정 2개가 선택되어 있습니다";
}

function pulseSelectedEmotionTags() {
  els.emotionList.querySelectorAll(".tag-chip.selected").forEach((chip) => {
    chip.classList.remove("limit-hit");
    void chip.offsetWidth;
    chip.classList.add("limit-hit");
  });
}

function buildSummary(checkins) {
  const topicCount = new Map();
  const emotionCount = new Map();

  checkins.forEach((checkin) => {
    checkin.keywords.forEach((keyword) => {
      topicCount.set(keyword, (topicCount.get(keyword) || 0) + 1);
    });
    checkin.emotions.forEach((emotion) => {
      emotionCount.set(emotion, (emotionCount.get(emotion) || 0) + 1);
    });
  });

  const topTopics = [...topicCount.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([keyword]) => keyword);

  const topEmotions = [...emotionCount.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([emotion]) => emotion);

  const summaryLine = createSummaryLine(topTopics, topEmotions);
  return { topTopics, topEmotions, summaryLine };
}

function setPatternStage(stage) {
  els.patternStage.dataset.stage = stage;
  els.patternStage.textContent = patternStageLabels[stage] || stage;
}

function updateInsightStrip(checkins) {
  els.checkinCount.textContent = `${checkins.length}회`;

  if (checkins.length === 0) {
    els.topEmotion.textContent = "아직 없음";
    return;
  }

  const emotionCount = new Map();
  checkins.forEach((checkin) => {
    checkin.emotions.forEach((emotion) => {
      emotionCount.set(emotion, (emotionCount.get(emotion) || 0) + 1);
    });
  });

  const topEmotion = [...emotionCount.entries()].sort((a, b) => b[1] - a[1])[0];
  els.topEmotion.textContent = topEmotion ? topEmotion[0] : "아직 없음";
}

function loadEvents() {
  try {
    const parsed = JSON.parse(localStorage.getItem(EVENT_STORAGE_KEY) || "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch (_error) {
    return [];
  }
}

function trackEvent(name, payload = {}) {
  const events = loadEvents();
  events.push({
    id: String(Date.now()) + Math.random().toString(16).slice(2, 8),
    name,
    payload,
    createdAt: new Date().toISOString(),
  });
  localStorage.setItem(EVENT_STORAGE_KEY, JSON.stringify(events));
}

function exportLocalData() {
  const payload = {
    exportedAt: new Date().toISOString(),
    checkins: loadCheckins(),
    events: loadEvents(),
  };

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = `second-self-export-${Date.now()}.json`;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  trackEvent("data_exported", {
    checkinCount: payload.checkins.length,
    eventCount: payload.events.length,
  });
  showToast("체크인과 이벤트 로그를 내보냈어요");
}

function showToast(message) {
  if (!els.toast) return;
  els.toast.textContent = message;
  els.toast.classList.add("visible");
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => {
    els.toast.classList.remove("visible");
  }, 1800);
}

function createSummaryLine(topTopics, topEmotions) {
  const firstTopic = topTopics[0] || "정리";
  const firstEmotion = topEmotions[0] || "혼란";
  const secondTopic = topTopics[1] || "";
  const hasDirection = topTopics.includes("방향성");
  const hasRelationship = topTopics.includes("관계");
  const hasWork = topTopics.includes("일");
  const hasRecovery = topTopics.includes("회복") || topTopics.includes("휴식");
  const hasPressure = topEmotions.includes("압박감");
  const hasAnxiety = topEmotions.includes("불안");

  if (hasDirection && hasAnxiety) {
    return "요즘 당신은 성과보다 앞으로의 방향을 더 자주 고민하고 있습니다.";
  }

  if (hasRelationship && hasAnxiety) {
    return "최근의 당신은 사람 사이의 거리와 마음의 안전함을 함께 살피고 있습니다.";
  }

  if (hasRelationship) {
    return "최근의 당신은 관계 속 거리와 연결감에 더 민감하게 반응하고 있습니다.";
  }

  if (hasWork && hasPressure) {
    return "당신은 해야 할 일의 무게 속에서도 흐름을 잃지 않으려 애쓰고 있습니다.";
  }

  if (hasRecovery) {
    return "최근의 당신은 더 밀어붙이기보다 회복할 수 있는 리듬을 찾고 있습니다.";
  }

  if (firstTopic === "방향성") {
    return "요즘의 당신은 지금 잘하고 있는지보다 어디로 가고 있는지를 더 자주 확인하고 있습니다.";
  }

  if (firstEmotion === "기대" && secondTopic) {
    return `최근의 당신은 ${secondTopic}에 대한 부담보다 가능성을 조금 더 오래 바라보고 있습니다.`;
  }

  return "최근의 당신은 흩어진 생각과 감정을 한데 모아 자기 흐름을 읽어내려 하고 있습니다.";
}

init();
