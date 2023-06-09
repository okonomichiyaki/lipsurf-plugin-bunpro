// lipsurf-plugins/src/Bunpro/Bunpro.ts
/// <reference types="lipsurf-types/extension"/>

declare const PluginBase: IPluginBase;

// stores the previous language before we started Bunpro context
var previousLanguage: LanguageCode;

const BUNPRO_HREF_REGX = /^https?:\/\/(www\.)?bunpro\.jp\/(learn|study|cram)/;

const particles: { [key: string]: string } = {
    "もう":"も",
    "わ":"は",
}

function activeElChange() {
	setTimeout(enterBunproContext, 200);
}

function fuzzyParticle(transcript: string): string {
    const maybe = particles[transcript]
    if (maybe === null) {
        return transcript;
    } else {
        return maybe
    }
}

function notEmpty<TValue>(value: TValue | null | undefined): value is TValue {
    return value !== null && value !== undefined;
}

function getTextFromRuby(ruby) {
  const childNodes = Array.from(ruby.childNodes);
  const textNodes = childNodes.filter(child => child.nodeType === Node.TEXT_NODE);
  return textNodes.map(child => child.textContent).join('');
}

function getKanaFromRuby(ruby) {
  const childNodes = Array.from(ruby.childNodes);
  const textNodes = childNodes.filter(child => child.nodeName === 'RT');
  return textNodes.map(child => child.textContent).join('');
}

function getText(div, rubyExtractor) {
  const spans = Array.from(div.querySelectorAll('span'));
  return spans.flatMap(function(span){
    const childNodes = Array.from(span.childNodes);
    return childNodes.map(function(child){
      if (child.nodeType === Node.TEXT_NODE || child.nodeName === 'STRONG') {
        return child.textContent;
      } else if (child.nodeName === 'RUBY') {
        return rubyExtractor(child);
      } else {
        console.log('[Bunpro.getText] unexpected child node: ', span, child);
        return child.textContent;
      }
    });
  }).join('');
}

function getTexts(div) {
  return [getText(div, getTextFromRuby), getText(div, getKanaFromRuby)];
}

function getExampleSentences() {
  const selector = 'div.example-sentence.japanese-example-sentence';
  const nodes = Array.from(document.querySelectorAll(selector));
  return nodes.flatMap(getTexts);
}

function getAnswers(): string[] {
    const official = Array.from(document.querySelectorAll('#answer_in_kana'))
        .map(answer => { return answer.getAttribute('data-answer'); })
        .filter(notEmpty);
  const examples = getExampleSentences();
  console.log('[Bunpro.getAnswers]', official);
  console.log('[Bunpro.getAnswers]', examples);
  return official.concat(examples);
}

export function matchAnswer({preTs, normTs}: TsData): [number, number, any[]?]|undefined|false {
    let transcript = normTs.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] candidate: t=%s,a=%o",transcript, answers);
    for (var i = 0; i < answers.length; i++) {
        const hiragana = answers[i];//katakanaToHiragana(answers[i]);
        if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
            console.log("[Bunpro.matchAnswer] found answer: a=%s h=%s t=%s", answers[i], hiragana, transcript);
            return [0, transcript.length, [answers[i]]];
        }
    }
    return undefined;
}

function inputAnswer({preTs, normTs}: TsData) {
    let transcript = normTs;
    // assumes that we matched a correct answer, so input the first answer from the page:
    const answers = getAnswers();
    if (answers.length < 1) {
        console.log("[Bunpro.inputAnswer] matched t=%s, but failed to find answers again", transcript);
    }
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
        (studyAreaInput as HTMLInputElement).value = answers[0];
        clickNext();
    } else {
        console.log("[Bunpro.inputAnswer] studyAreaInput was null");
    }
}

function markWrong() {
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
        (studyAreaInput as HTMLInputElement).value = "あああ";
        clickNext();
    } else {
        console.log("[Bunpro.markWrong] studyAreaInput was null");
    }
    if (PluginBase.getPluginOption('Bunpro', 'Automatically show answer') === true) {
        clickElement('#show-answer');
    }
}

function clickElement(selector: string) {
    const element = document.querySelector(selector) as HTMLElement;
    if (element !== null) {
        element.click();
    } else {
        console.log("[Bunpro.clickElement] %s was null", selector)
    }
}

// alternates
// #study-page > section.grammar-point.review-grammar-point > header > div.alternate-grammar
// or 'a'

// undo
// #study-page > section.grammar-point.review-grammar-point > div.study-input-bar > div.col-xs-2.col-sm-1.undo-button.tooltip.tooltipstered
// or backspace

function clickNext() {
    clickElement("#submit-study-answer");
}

function clickHint() {
    clickElement("#show-english-hint");
}

function clickShowGrammar() {
    clickElement("#show-grammar");
}

function enterBunproContext() {
    console.log("[Bunpro.enterBunproContext]");
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.enterContext(["Bunpro"]);
    PluginBase.util.setLanguage("ja");
}

function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]");
    PluginBase.util.enterContext(["Normal"]);
    if (previousLanguage !== null) {
        PluginBase.util.setLanguage(previousLanguage);
    }
}

function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s",document.location.href);
    if (document.location.href.match(BUNPRO_HREF_REGX)) {
        enterBunproContext();
    } else {
        exitBunproContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Bunpro",
    description: "",
    match: /.*bunpro.jp.*/,
    apiVersion: 2,
    version: "0.0.5",
    init: () => {
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
        })(history.replaceState);`
        var head = document.getElementsByTagName("head")[0];         
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.innerHTML = src;
        head.appendChild(script);
        window.addEventListener('locationchange', locationChangeHandler); 
        locationChangeHandler();
    },
    destroy: () => {
        window.removeEventListener("blur", activeElChange);
        window.removeEventListener('locationchange', locationChangeHandler);
        exitBunproContext();
    },
    contexts: {
        "Bunpro": {
            commands: [
                "LipSurf.Change Language to Japanese",
                "LipSurf.Normal Mode",
                "LipSurf.Turn off LipSurf",
                "Answer",
                "Hint",
                "Next",
                "Wrong",
                "Info"
            ]
        }
    },
    settings: [
        {
            name: 'Automatically show answer',
            type: 'boolean',
            default: true,
        }
    ],
    commands: [
        {
            name: "Answer",
            description: "Submit an answer for a Bunpro review",
            match: {
                description: "[answer]",
                fn: matchAnswer
            },
            normal: false,
            pageFn: inputAnswer
        }, {
            name: "Hint",
            description: "Toggle the translated hint",
            match: "hint",
            normal: false,
            pageFn: clickHint
        }, {
            name: "Next",
            description: "Go to the next card",
            match: "next",
            normal: false,
            pageFn: clickNext
        }, {
            name: "Wrong",
            description: "Mark a card wrong",
            match: "wrong",
            normal: false,
            pageFn: markWrong
        }, {
            name: "Info",
            description: "Show grammar info",
            match: "info",
            normal: false,
            pageFn: clickShowGrammar
        }
    ]
}};
