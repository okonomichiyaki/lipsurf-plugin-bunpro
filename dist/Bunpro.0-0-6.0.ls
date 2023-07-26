import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';// dist/tmp/Bunpro/Bunpro.js
var particles = { "もう": "も", "わ": "は" };
function fuzzyParticle(transcript) {
  const maybe = particles[transcript];
  if (maybe === null) {
    return transcript;
  } else {
    return maybe;
  }
}
function getTextFromRuby(ruby) {
  const childNodes = Array.from(ruby.childNodes);
  const textNodes = childNodes.filter((child) => child.nodeType === Node.TEXT_NODE);
  return textNodes.map((child) => child.textContent).join("");
}
function getKanaFromRuby(ruby) {
  const childNodes = Array.from(ruby.childNodes);
  const textNodes = childNodes.filter((child) => child.nodeName === "RT");
  return textNodes.map((child) => child.textContent).join("");
}
function getText(div, rubyExtractor) {
  const spans = Array.from(div.querySelectorAll("span"));
  return spans.flatMap(function(span) {
    const childNodes = Array.from(span.childNodes);
    return childNodes.map(function(child) {
      if (child.nodeType === Node.TEXT_NODE || child.nodeName === "STRONG") {
        return child.textContent;
      } else if (child.nodeName === "RUBY") {
        return rubyExtractor(child);
      } else {
        console.log("[Bunpro.getText] unexpected child node: ", span, child);
        return child.textContent;
      }
    });
  }).join("");
}
function getTexts(div) {
  return [getText(div, getTextFromRuby), getText(div, getKanaFromRuby)];
}
function getExampleSentences() {
  const selector = "div.example-sentence.japanese-example-sentence";
  const nodes = Array.from(document.querySelectorAll(selector));
  return nodes.flatMap(getTexts);
}
function getAnswers() {
  const official = Array.from(document.querySelectorAll("#quiz-metadata-element")).flatMap((metadata) => {
    const json = metadata.getAttribute("data-meta-answers-array");
    if (json) {
      return JSON.parse(json);
    } else {
      return [];
    }
  });
  const examples = getExampleSentences();
  console.log("[Bunpro.getAnswers]", official);
  console.log("[Bunpro.getAnswers]", examples);
  return official.concat(examples);
}
var Bunpro_default = { "languages": { "ja": { "niceName": "Bunpro", "description": "Bunpro", "commands": { "Answer": { "name": "答え (answer)", "match": { "description": "[Bunproの答え]", "fn": function matchAnswer({ preTs, normTs }) {
  let transcript = normTs.toLowerCase();
  const answers = getAnswers();
  console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o", transcript, answers);
  for (var i = 0; i < answers.length; i++) {
    const hiragana = answers[i];
    if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
      console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
      return [0, transcript.length, [answers[i]]];
    }
  }
  return void 0;
} } }, "Hint": { "name": "暗示 (hint)", "match": ["ひんと", "あんじ"] }, "Next": { "name": "次へ (next)", "match": ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, "Wrong": { "name": "バツ (wrong)", "match": ["だめ", "ばつ"] }, "Info": { "name": "情報 (info)", "match": ["じょうほう"] } } } }, "niceName": "Bunpro", "description": "", "match": /.*bunpro.jp.*/, "apiVersion": 2, "version": "0.0.6", "contexts": { "Bunpro": { "commands": ["LipSurf.Change Language to Japanese", "LipSurf.Normal Mode", "LipSurf.Turn off LipSurf", "Answer", "Hint", "Next", "Wrong", "Info"] } }, "settings": [{ "name": "Automatically show answer", "type": "boolean", "default": true }, { "name": "Lightning mode", "type": "boolean", "default": true }], "commands": [{ "name": "Answer", "description": "Submit an answer for a Bunpro review", "match": { "description": "[answer]", "fn": () => {
} }, "normal": false }, { "name": "Hint", "description": "Toggle the translated hint", "match": "hint", "normal": false }, { "name": "Next", "description": "Go to the next card", "match": "next", "normal": false }, { "name": "Wrong", "description": "Mark a card wrong", "match": "wrong", "normal": false }, { "name": "Info", "description": "Show grammar info", "match": "info", "normal": false }] };
export {
  Bunpro_default as default
};
LS-SPLIT// dist/tmp/Bunpro/Bunpro.js
window.allPlugins.Bunpro = (() => {
  var previousLanguage;
  var BUNPRO_HREF_REGX = /^https?:\/\/(www\.)?bunpro\.jp\/(reviews|cram|learn).*/;
  var particles = { "もう": "も", "わ": "は" };
  function activeElChange() {
    setTimeout(enterBunproContext, 200);
  }
  function fuzzyParticle(transcript) {
    const maybe = particles[transcript];
    if (maybe === null) {
      return transcript;
    } else {
      return maybe;
    }
  }
  function getTextFromRuby(ruby) {
    const childNodes = Array.from(ruby.childNodes);
    const textNodes = childNodes.filter((child) => child.nodeType === Node.TEXT_NODE);
    return textNodes.map((child) => child.textContent).join("");
  }
  function getKanaFromRuby(ruby) {
    const childNodes = Array.from(ruby.childNodes);
    const textNodes = childNodes.filter((child) => child.nodeName === "RT");
    return textNodes.map((child) => child.textContent).join("");
  }
  function getText(div, rubyExtractor) {
    const spans = Array.from(div.querySelectorAll("span"));
    return spans.flatMap(function(span) {
      const childNodes = Array.from(span.childNodes);
      return childNodes.map(function(child) {
        if (child.nodeType === Node.TEXT_NODE || child.nodeName === "STRONG") {
          return child.textContent;
        } else if (child.nodeName === "RUBY") {
          return rubyExtractor(child);
        } else {
          console.log("[Bunpro.getText] unexpected child node: ", span, child);
          return child.textContent;
        }
      });
    }).join("");
  }
  function getTexts(div) {
    return [getText(div, getTextFromRuby), getText(div, getKanaFromRuby)];
  }
  function getExampleSentences() {
    const selector = "div.example-sentence.japanese-example-sentence";
    const nodes = Array.from(document.querySelectorAll(selector));
    return nodes.flatMap(getTexts);
  }
  function getAnswers() {
    const official = Array.from(document.querySelectorAll("#quiz-metadata-element")).flatMap((metadata) => {
      const json = metadata.getAttribute("data-meta-answers-array");
      if (json) {
        return JSON.parse(json);
      } else {
        return [];
      }
    });
    const examples = getExampleSentences();
    console.log("[Bunpro.getAnswers]", official);
    console.log("[Bunpro.getAnswers]", examples);
    return official.concat(examples);
  }
  function matchAnswer({ preTs, normTs }) {
    let transcript = normTs.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      const hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
        console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
        return [0, transcript.length, [answers[i]]];
      }
    }
    return void 0;
  }
  function getButtonWithTitle(title) {
    const buttons = document.querySelectorAll("#js-quiz button");
    if (buttons.length === 0) {
      console.error("[Bunpro.getBlankButton] fatal error, no buttons found for query `#js-quiz button`");
      return null;
    }
    const expected = Array.from(buttons).filter((b) => b.title === title);
    if (expected.length === 0) {
      console.error(`[Bunpro.getBlankButton] fatal error, no buttons found with title ${title}`);
      return null;
    }
    return expected[0];
  }
  function clickButtonWithTitle(title) {
    const button = getButtonWithTitle(title);
    if (button) {
      button.click();
    }
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    const answers = getAnswers();
    if (answers.length < 1) {
      console.log("[Bunpro.inputAnswer] matched t=%s, but failed to find answers again", transcript);
    }
    const answer = answers[0];
    const inputEl = document.querySelector(".InputManual__input");
    const event = new Event("input", { bubbles: true });
    inputEl.value = answer;
    inputEl.dispatchEvent(event);
    setTimeout(() => {
      const submitButton = document.querySelector(".InputManual__button");
      submitButton.click();
      if (PluginBase.getPluginOption("Bunpro", "Lightning mode") === true) {
        setTimeout(clickNext, 100);
      }
    }, 50);
  }
  function markWrong() {
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
      studyAreaInput.value = "あああ";
      clickNext();
    } else {
      console.log("[Bunpro.markWrong] studyAreaInput was null");
    }
    if (PluginBase.getPluginOption("Bunpro", "Automatically show answer") === true) {
      clickElement("#show-answer");
    }
  }
  function clickElement(selector) {
    const element = document.querySelector(selector);
    if (element !== null) {
      element.click();
    } else {
      console.log("[Bunpro.clickElement] %s was null", selector);
    }
  }
  function clickNext() {
    clickButtonWithTitle("Next question");
  }
  function clickHint() {
    clickElement("#show-english-hint");
  }
  function clickShowGrammar() {
    clickElement("#show-grammar");
  }
  function mutationCallback(mutations, observer) {
    const meta = document.querySelectorAll("#quiz-metadata-element");
    if (meta && meta.length > 0 && meta[0].getAttribute("data-meta-question-mode") === "translate") {
      PluginBase.util.setLanguage("en");
    } else {
      PluginBase.util.setLanguage("ja");
    }
  }
  function enterBunproContext() {
    console.log("[Bunpro.enterBunproContext]");
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.enterContext(["Bunpro"]);
    PluginBase.util.setLanguage("ja");
    const config = { attributes: true, childList: true, subtree: true };
    const observer = new MutationObserver(mutationCallback);
    observer.observe(document.body, config);
    mutationCallback(null, null);
  }
  function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]");
    PluginBase.util.enterContext(["Normal"]);
    if (previousLanguage !== null) {
      PluginBase.util.setLanguage(previousLanguage);
    }
  }
  function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s", document.location.href);
    if (document.location.href.match(BUNPRO_HREF_REGX)) {
      enterBunproContext();
    } else {
      exitBunproContext();
    }
  }
  var Bunpro_default = { ...PluginBase, ...{ "init": () => {
    window.addEventListener("blur", activeElChange, true);
    previousLanguage = PluginBase.util.getLanguage();
    const src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`;
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.innerHTML = src;
    head.appendChild(script);
    window.addEventListener("locationchange", locationChangeHandler);
    locationChangeHandler();
  }, "destroy": () => {
    window.removeEventListener("blur", activeElChange);
    window.removeEventListener("locationchange", locationChangeHandler);
    exitBunproContext();
  }, "commands": { "Answer": { "match": { "en": function matchAnswer2({ preTs, normTs }) {
    let transcript = normTs.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      const hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
        console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
        return [0, transcript.length, [answers[i]]];
      }
    }
    return void 0;
  }, "ja": function matchAnswer2({ preTs, normTs }) {
    let transcript = normTs.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      const hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
        console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
        return [0, transcript.length, [answers[i]]];
      }
    }
    return void 0;
  } }, "pageFn": function inputAnswer2({ preTs, normTs }) {
    let transcript = normTs;
    const answers = getAnswers();
    if (answers.length < 1) {
      console.log("[Bunpro.inputAnswer] matched t=%s, but failed to find answers again", transcript);
    }
    const answer = answers[0];
    const inputEl = document.querySelector(".InputManual__input");
    const event = new Event("input", { bubbles: true });
    inputEl.value = answer;
    inputEl.dispatchEvent(event);
    setTimeout(() => {
      const submitButton = document.querySelector(".InputManual__button");
      submitButton.click();
      if (PluginBase.getPluginOption("Bunpro", "Lightning mode") === true) {
        setTimeout(clickNext, 100);
      }
    }, 50);
  } }, "Hint": { "pageFn": function clickHint2() {
    clickElement("#show-english-hint");
  } }, "Next": { "pageFn": function clickNext2() {
    clickButtonWithTitle("Next question");
  } }, "Wrong": { "pageFn": function markWrong2() {
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
      studyAreaInput.value = "あああ";
      clickNext();
    } else {
      console.log("[Bunpro.markWrong] studyAreaInput was null");
    }
    if (PluginBase.getPluginOption("Bunpro", "Automatically show answer") === true) {
      clickElement("#show-answer");
    }
  } }, "Info": { "pageFn": function clickShowGrammar2() {
    clickElement("#show-grammar");
  } } } } };
  Bunpro_default.languages.ja = { niceName: "Bunpro", description: "Bunpro", commands: { "Answer": { name: "答え (answer)", match: { description: "[Bunproの答え]", fn: matchAnswer } }, "Hint": { name: "暗示 (hint)", match: ["ひんと", "あんじ"] }, "Next": { name: "次へ (next)", match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, "Wrong": { name: "バツ (wrong)", match: ["だめ", "ばつ"] }, "Info": { name: "情報 (info)", match: ["じょうほう"] } } };
  return Bunpro_default;
})();
LS-SPLIT// dist/tmp/Bunpro/Bunpro.js
window.allPlugins.Bunpro = (() => {
  var previousLanguage;
  var BUNPRO_HREF_REGX = /^https?:\/\/(www\.)?bunpro\.jp\/(reviews|cram|learn).*/;
  var particles = { "もう": "も", "わ": "は" };
  function activeElChange() {
    setTimeout(enterBunproContext, 200);
  }
  function fuzzyParticle(transcript) {
    const maybe = particles[transcript];
    if (maybe === null) {
      return transcript;
    } else {
      return maybe;
    }
  }
  function getTextFromRuby(ruby) {
    const childNodes = Array.from(ruby.childNodes);
    const textNodes = childNodes.filter((child) => child.nodeType === Node.TEXT_NODE);
    return textNodes.map((child) => child.textContent).join("");
  }
  function getKanaFromRuby(ruby) {
    const childNodes = Array.from(ruby.childNodes);
    const textNodes = childNodes.filter((child) => child.nodeName === "RT");
    return textNodes.map((child) => child.textContent).join("");
  }
  function getText(div, rubyExtractor) {
    const spans = Array.from(div.querySelectorAll("span"));
    return spans.flatMap(function(span) {
      const childNodes = Array.from(span.childNodes);
      return childNodes.map(function(child) {
        if (child.nodeType === Node.TEXT_NODE || child.nodeName === "STRONG") {
          return child.textContent;
        } else if (child.nodeName === "RUBY") {
          return rubyExtractor(child);
        } else {
          console.log("[Bunpro.getText] unexpected child node: ", span, child);
          return child.textContent;
        }
      });
    }).join("");
  }
  function getTexts(div) {
    return [getText(div, getTextFromRuby), getText(div, getKanaFromRuby)];
  }
  function getExampleSentences() {
    const selector = "div.example-sentence.japanese-example-sentence";
    const nodes = Array.from(document.querySelectorAll(selector));
    return nodes.flatMap(getTexts);
  }
  function getAnswers() {
    const official = Array.from(document.querySelectorAll("#quiz-metadata-element")).flatMap((metadata) => {
      const json = metadata.getAttribute("data-meta-answers-array");
      if (json) {
        return JSON.parse(json);
      } else {
        return [];
      }
    });
    const examples = getExampleSentences();
    console.log("[Bunpro.getAnswers]", official);
    console.log("[Bunpro.getAnswers]", examples);
    return official.concat(examples);
  }
  function matchAnswer({ preTs, normTs }) {
    let transcript = normTs.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      const hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
        console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
        return [0, transcript.length, [answers[i]]];
      }
    }
    return void 0;
  }
  function getButtonWithTitle(title) {
    const buttons = document.querySelectorAll("#js-quiz button");
    if (buttons.length === 0) {
      console.error("[Bunpro.getBlankButton] fatal error, no buttons found for query `#js-quiz button`");
      return null;
    }
    const expected = Array.from(buttons).filter((b) => b.title === title);
    if (expected.length === 0) {
      console.error(`[Bunpro.getBlankButton] fatal error, no buttons found with title ${title}`);
      return null;
    }
    return expected[0];
  }
  function clickButtonWithTitle(title) {
    const button = getButtonWithTitle(title);
    if (button) {
      button.click();
    }
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    const answers = getAnswers();
    if (answers.length < 1) {
      console.log("[Bunpro.inputAnswer] matched t=%s, but failed to find answers again", transcript);
    }
    const answer = answers[0];
    const inputEl = document.querySelector(".InputManual__input");
    const event = new Event("input", { bubbles: true });
    inputEl.value = answer;
    inputEl.dispatchEvent(event);
    setTimeout(() => {
      const submitButton = document.querySelector(".InputManual__button");
      submitButton.click();
      if (PluginBase.getPluginOption("Bunpro", "Lightning mode") === true) {
        setTimeout(clickNext, 100);
      }
    }, 50);
  }
  function markWrong() {
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
      studyAreaInput.value = "あああ";
      clickNext();
    } else {
      console.log("[Bunpro.markWrong] studyAreaInput was null");
    }
    if (PluginBase.getPluginOption("Bunpro", "Automatically show answer") === true) {
      clickElement("#show-answer");
    }
  }
  function clickElement(selector) {
    const element = document.querySelector(selector);
    if (element !== null) {
      element.click();
    } else {
      console.log("[Bunpro.clickElement] %s was null", selector);
    }
  }
  function clickNext() {
    clickButtonWithTitle("Next question");
  }
  function clickHint() {
    clickElement("#show-english-hint");
  }
  function clickShowGrammar() {
    clickElement("#show-grammar");
  }
  function mutationCallback(mutations, observer) {
    const meta = document.querySelectorAll("#quiz-metadata-element");
    if (meta && meta.length > 0 && meta[0].getAttribute("data-meta-question-mode") === "translate") {
      PluginBase.util.setLanguage("en");
    } else {
      PluginBase.util.setLanguage("ja");
    }
  }
  function enterBunproContext() {
    console.log("[Bunpro.enterBunproContext]");
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.enterContext(["Bunpro"]);
    PluginBase.util.setLanguage("ja");
    const config = { attributes: true, childList: true, subtree: true };
    const observer = new MutationObserver(mutationCallback);
    observer.observe(document.body, config);
    mutationCallback(null, null);
  }
  function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]");
    PluginBase.util.enterContext(["Normal"]);
    if (previousLanguage !== null) {
      PluginBase.util.setLanguage(previousLanguage);
    }
  }
  function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s", document.location.href);
    if (document.location.href.match(BUNPRO_HREF_REGX)) {
      enterBunproContext();
    } else {
      exitBunproContext();
    }
  }
  var Bunpro_default = { ...PluginBase, ...{ "init": () => {
    window.addEventListener("blur", activeElChange, true);
    previousLanguage = PluginBase.util.getLanguage();
    const src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`;
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.innerHTML = src;
    head.appendChild(script);
    window.addEventListener("locationchange", locationChangeHandler);
    locationChangeHandler();
  }, "destroy": () => {
    window.removeEventListener("blur", activeElChange);
    window.removeEventListener("locationchange", locationChangeHandler);
    exitBunproContext();
  }, "commands": {} } };
  Bunpro_default.languages.ja = { niceName: "Bunpro", description: "Bunpro", commands: { "Answer": { name: "答え (answer)", match: { description: "[Bunproの答え]", fn: matchAnswer } }, "Hint": { name: "暗示 (hint)", match: ["ひんと", "あんじ"] }, "Next": { name: "次へ (next)", match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, "Wrong": { name: "バツ (wrong)", match: ["だめ", "ばつ"] }, "Info": { name: "情報 (info)", match: ["じょうほう"] } } };
  return Bunpro_default;
})();
