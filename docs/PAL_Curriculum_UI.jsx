import React, { useState, useRef, useEffect } from 'react';
import { Search, X, ChevronUp, ChevronDown, Sparkles, Dumbbell, Settings2, Zap, RefreshCw, Check, Loader2 } from 'lucide-react';

// 운동 데이터 샘플 (실제로는 800개 한국어 DB에서 가져옴)
const exerciseDatabase = [
  { id: 1, name: "바벨 벤치프레스", equipment: "바벨", primaryMuscle: "가슴" },
  { id: 2, name: "덤벨 벤치프레스", equipment: "덤벨", primaryMuscle: "가슴" },
  { id: 3, name: "인클라인 덤벨프레스", equipment: "덤벨", primaryMuscle: "가슴" },
  { id: 4, name: "케이블 크로스오버", equipment: "케이블", primaryMuscle: "가슴" },
  { id: 5, name: "펙덱 플라이", equipment: "머신", primaryMuscle: "가슴" },
  { id: 6, name: "레그프레스", equipment: "머신", primaryMuscle: "하체" },
  { id: 7, name: "스미스머신 스쿼트", equipment: "스미스머신", primaryMuscle: "하체" },
  { id: 8, name: "바벨 스쿼트", equipment: "바벨", primaryMuscle: "하체" },
  { id: 9, name: "레그 익스텐션", equipment: "머신", primaryMuscle: "하체" },
  { id: 10, name: "레그 컬", equipment: "머신", primaryMuscle: "하체" },
  { id: 11, name: "랫풀다운", equipment: "케이블", primaryMuscle: "등" },
  { id: 12, name: "시티드 로우", equipment: "케이블", primaryMuscle: "등" },
  { id: 13, name: "바벨 로우", equipment: "바벨", primaryMuscle: "등" },
  { id: 14, name: "덤벨 로우", equipment: "덤벨", primaryMuscle: "등" },
  { id: 15, name: "풀업", equipment: "맨몸", primaryMuscle: "등" },
  { id: 16, name: "숄더프레스", equipment: "덤벨", primaryMuscle: "어깨" },
  { id: 17, name: "사이드 레터럴 레이즈", equipment: "덤벨", primaryMuscle: "어깨" },
  { id: 18, name: "프론트 레이즈", equipment: "덤벨", primaryMuscle: "어깨" },
  { id: 19, name: "바벨 컬", equipment: "바벨", primaryMuscle: "팔" },
  { id: 20, name: "덤벨 컬", equipment: "덤벨", primaryMuscle: "팔" },
  { id: 21, name: "트라이셉 푸시다운", equipment: "케이블", primaryMuscle: "팔" },
  { id: 22, name: "크런치", equipment: "맨몸", primaryMuscle: "복근" },
  { id: 23, name: "플랭크", equipment: "맨몸", primaryMuscle: "복근" },
  { id: 24, name: "레그레이즈", equipment: "맨몸", primaryMuscle: "복근" },
];

// 휠 피커 컴포넌트
const WheelPicker = ({ value, onChange, min = 1, max = 10, label }) => {
  const [isOpen, setIsOpen] = useState(false);
  const values = Array.from({ length: max - min + 1 }, (_, i) => min + i);
  
  return (
    <div className="flex flex-col items-center gap-2">
      <span className="text-xs text-slate-400 uppercase tracking-wider">{label}</span>
      <div className="relative">
        <div 
          className="w-16 h-16 bg-slate-800/50 rounded-2xl flex items-center justify-center cursor-pointer border border-slate-700/50 hover:border-emerald-500/50 transition-all"
          onClick={() => setIsOpen(!isOpen)}
        >
          <span className="text-2xl font-bold text-white">{value}</span>
        </div>
        
        {isOpen && (
          <div className="absolute top-full left-1/2 -translate-x-1/2 mt-2 bg-slate-800 rounded-xl border border-slate-700 shadow-2xl z-50 overflow-hidden">
            <div className="max-h-48 overflow-y-auto py-1 scrollbar-thin">
              {values.map((v) => (
                <div
                  key={v}
                  className={`px-6 py-2 text-center cursor-pointer transition-all ${
                    v === value 
                      ? 'bg-emerald-500 text-white font-bold' 
                      : 'text-slate-300 hover:bg-slate-700'
                  }`}
                  onClick={() => {
                    onChange(v);
                    setIsOpen(false);
                  }}
                >
                  {v}
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
      <div className="flex flex-col gap-1">
        <button 
          onClick={() => value < max && onChange(value + 1)}
          className="p-1 text-slate-500 hover:text-emerald-400 transition-colors"
        >
          <ChevronUp size={16} />
        </button>
        <button 
          onClick={() => value > min && onChange(value - 1)}
          className="p-1 text-slate-500 hover:text-emerald-400 transition-colors"
        >
          <ChevronDown size={16} />
        </button>
      </div>
    </div>
  );
};

// 칩 버튼 컴포넌트
const ChipButton = ({ label, selected, onClick, variant = "default" }) => {
  const variants = {
    default: selected 
      ? "bg-emerald-500 text-white border-emerald-500" 
      : "bg-slate-800/50 text-slate-300 border-slate-700 hover:border-emerald-500/50",
    danger: selected 
      ? "bg-red-500/20 text-red-400 border-red-500/50" 
      : "bg-slate-800/50 text-slate-300 border-slate-700 hover:border-red-500/50",
  };
  
  return (
    <button
      onClick={onClick}
      className={`px-3 py-1.5 rounded-full text-sm border transition-all ${variants[variant]}`}
    >
      {label}
    </button>
  );
};

// 운동 검색 컴포넌트
const ExerciseSearch = ({ excludedExercises, onExclude, onRemove }) => {
  const [query, setQuery] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const inputRef = useRef(null);
  
  const filteredExercises = query.length > 0
    ? exerciseDatabase.filter(ex => 
        ex.name.toLowerCase().includes(query.toLowerCase()) &&
        !excludedExercises.find(e => e.id === ex.id)
      ).slice(0, 5)
    : [];
  
  return (
    <div className="space-y-3">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
        <input
          ref={inputRef}
          type="text"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setIsOpen(true);
          }}
          onFocus={() => setIsOpen(true)}
          placeholder="제외할 운동 검색..."
          className="w-full bg-slate-800/50 border border-slate-700 rounded-xl pl-10 pr-4 py-3 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 transition-colors"
        />
        
        {isOpen && filteredExercises.length > 0 && (
          <div className="absolute top-full left-0 right-0 mt-2 bg-slate-800 rounded-xl border border-slate-700 shadow-2xl z-50 overflow-hidden">
            {filteredExercises.map((exercise) => (
              <div
                key={exercise.id}
                className="px-4 py-3 hover:bg-slate-700 cursor-pointer transition-colors flex justify-between items-center"
                onClick={() => {
                  onExclude(exercise);
                  setQuery("");
                  setIsOpen(false);
                }}
              >
                <div>
                  <span className="text-white">{exercise.name}</span>
                  <span className="text-slate-500 text-sm ml-2">{exercise.equipment}</span>
                </div>
                <span className="text-xs text-slate-500 bg-slate-700/50 px-2 py-1 rounded">
                  {exercise.primaryMuscle}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
      
      {excludedExercises.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {excludedExercises.map((exercise) => (
            <span
              key={exercise.id}
              className="inline-flex items-center gap-1 px-3 py-1.5 bg-red-500/10 text-red-400 border border-red-500/30 rounded-full text-sm"
            >
              {exercise.name}
              <X 
                size={14} 
                className="cursor-pointer hover:text-red-300" 
                onClick={() => onRemove(exercise.id)}
              />
            </span>
          ))}
        </div>
      )}
    </div>
  );
};

// AI 생성된 커리큘럼 카드
const CurriculumCard = ({ exercise, index, onReplace, onEdit }) => {
  const [showAlternatives, setShowAlternatives] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  
  // 대체 운동 샘플
  const alternatives = exerciseDatabase
    .filter(ex => ex.primaryMuscle === exercise.primaryMuscle && ex.id !== exercise.id)
    .slice(0, 3);
  
  return (
    <div className="bg-slate-800/30 rounded-xl border border-slate-700/50 p-4 hover:border-emerald-500/30 transition-all group">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <span className="w-8 h-8 bg-emerald-500/20 text-emerald-400 rounded-lg flex items-center justify-center font-bold text-sm">
            {index + 1}
          </span>
          <div>
            <h4 className="text-white font-medium">{exercise.name}</h4>
            <p className="text-slate-500 text-sm">{exercise.sets}세트 × {exercise.reps}회</p>
          </div>
        </div>
        
        <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <button 
            onClick={() => setShowAlternatives(!showAlternatives)}
            className="p-2 text-slate-400 hover:text-emerald-400 hover:bg-emerald-500/10 rounded-lg transition-all"
            title="대체 운동"
          >
            <RefreshCw size={16} />
          </button>
          <button 
            onClick={() => setIsEditing(!isEditing)}
            className="p-2 text-slate-400 hover:text-blue-400 hover:bg-blue-500/10 rounded-lg transition-all"
            title="직접 수정"
          >
            <Settings2 size={16} />
          </button>
        </div>
      </div>
      
      {showAlternatives && (
        <div className="mt-4 pt-4 border-t border-slate-700/50">
          <p className="text-xs text-slate-500 mb-2">대체 운동 추천</p>
          <div className="flex flex-wrap gap-2">
            {alternatives.map((alt) => (
              <button
                key={alt.id}
                onClick={() => {
                  onReplace(index, { ...alt, sets: exercise.sets, reps: exercise.reps });
                  setShowAlternatives(false);
                }}
                className="px-3 py-1.5 bg-slate-700/50 text-slate-300 rounded-lg text-sm hover:bg-emerald-500/20 hover:text-emerald-400 transition-all"
              >
                {alt.name}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

// 메인 컴포넌트
export default function AICurriculumGenerator() {
  // 설정 상태
  const [exerciseCount, setExerciseCount] = useState(5);
  const [setCount, setSetCount] = useState(3);
  const [focusParts, setFocusParts] = useState([]);
  const [excludedExercises, setExcludedExercises] = useState([]);
  const [excludedBodyParts, setExcludedBodyParts] = useState([]);
  const [exerciseStyles, setExerciseStyles] = useState([]);
  const [additionalNotes, setAdditionalNotes] = useState("");
  
  // 생성 상태
  const [step, setStep] = useState("settings"); // settings | generating | result
  const [generatedCurriculum, setGeneratedCurriculum] = useState([]);
  
  const bodyParts = ["가슴", "등", "하체", "어깨", "팔", "복근", "전신"];
  const injuryParts = ["어깨", "허리", "무릎", "손목", "발목", "목", "팔꿈치", "고관절"];
  const styles = [
    { id: "heavy", label: "고중량" },
    { id: "light", label: "저중량" },
    { id: "highRep", label: "고반복" },
    { id: "lowRep", label: "저반복" },
    { id: "circuit", label: "서킷" },
    { id: "superset", label: "슈퍼세트" },
    { id: "dropset", label: "드롭세트" },
    { id: "pyramid", label: "피라미드" },
    { id: "giantset", label: "자이언트세트" },
    { id: "compound", label: "컴파운드 위주" },
    { id: "isolation", label: "고립 위주" },
    { id: "strength", label: "스트렝스" },
    { id: "hypertrophy", label: "근비대" },
    { id: "endurance", label: "근지구력" },
  ];
  
  const toggleArray = (arr, setArr, value) => {
    if (arr.includes(value)) {
      setArr(arr.filter(v => v !== value));
    } else {
      setArr([...arr, value]);
    }
  };
  
  const handleGenerate = () => {
    setStep("generating");
    
    // 시뮬레이션: AI 생성 (실제로는 Cloud Function 호출)
    setTimeout(() => {
      const mockCurriculum = [
        { id: 1, name: "바벨 벤치프레스", sets: setCount, reps: 12, primaryMuscle: "가슴" },
        { id: 2, name: "인클라인 덤벨프레스", sets: setCount, reps: 12, primaryMuscle: "가슴" },
        { id: 3, name: "펙덱 플라이", sets: setCount, reps: 15, primaryMuscle: "가슴" },
        { id: 4, name: "케이블 크로스오버", sets: setCount, reps: 15, primaryMuscle: "가슴" },
        { id: 5, name: "푸시업", sets: setCount, reps: 15, primaryMuscle: "가슴" },
      ].slice(0, exerciseCount);
      
      setGeneratedCurriculum(mockCurriculum);
      setStep("result");
    }, 2000);
  };
  
  const handleReplace = (index, newExercise) => {
    const updated = [...generatedCurriculum];
    updated[index] = newExercise;
    setGeneratedCurriculum(updated);
  };
  
  const handleConfirm = () => {
    alert("커리큘럼이 저장되었습니다!");
    // 실제로는 Firestore에 저장
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-white p-4 md:p-6">
      {/* 헤더 */}
      <div className="max-w-2xl mx-auto mb-8">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-10 h-10 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-xl flex items-center justify-center">
            <Sparkles size={20} className="text-white" />
          </div>
          <h1 className="text-2xl font-bold">AI 커리큘럼 생성</h1>
        </div>
        <p className="text-slate-400">조건을 설정하면 AI가 맞춤 커리큘럼을 생성합니다</p>
      </div>
      
      <div className="max-w-2xl mx-auto">
        {/* 설정 화면 */}
        {step === "settings" && (
          <div className="space-y-6">
            {/* 종목 수 & 세트 수 */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4 flex items-center gap-2">
                <Dumbbell size={16} />
                기본 설정
              </h3>
              <div className="flex justify-center gap-12">
                <WheelPicker 
                  value={exerciseCount} 
                  onChange={setExerciseCount} 
                  min={1} 
                  max={10} 
                  label="종목 수" 
                />
                <WheelPicker 
                  value={setCount} 
                  onChange={setSetCount} 
                  min={1} 
                  max={10} 
                  label="세트 수" 
                />
              </div>
            </div>
            
            {/* 집중 부위 */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4">집중 부위</h3>
              <div className="flex flex-wrap gap-2">
                {bodyParts.map((part) => (
                  <ChipButton
                    key={part}
                    label={part}
                    selected={focusParts.includes(part)}
                    onClick={() => toggleArray(focusParts, setFocusParts, part)}
                  />
                ))}
              </div>
            </div>
            
            {/* 제외 운동 */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4">제외 운동</h3>
              <ExerciseSearch
                excludedExercises={excludedExercises}
                onExclude={(ex) => setExcludedExercises([...excludedExercises, ex])}
                onRemove={(id) => setExcludedExercises(excludedExercises.filter(e => e.id !== id))}
              />
            </div>
            
            {/* 제외 부위 (부상/통증) */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4">제외 부위 (부상/통증)</h3>
              <div className="flex flex-wrap gap-2">
                {injuryParts.map((part) => (
                  <ChipButton
                    key={part}
                    label={part}
                    selected={excludedBodyParts.includes(part)}
                    onClick={() => toggleArray(excludedBodyParts, setExcludedBodyParts, part)}
                    variant="danger"
                  />
                ))}
              </div>
            </div>
            
            {/* 운동 스타일 */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4 flex items-center gap-2">
                <Zap size={16} />
                운동 스타일
              </h3>
              <div className="flex flex-wrap gap-2">
                {styles.map((style) => (
                  <ChipButton
                    key={style.id}
                    label={style.label}
                    selected={exerciseStyles.includes(style.id)}
                    onClick={() => toggleArray(exerciseStyles, setExerciseStyles, style.id)}
                  />
                ))}
              </div>
            </div>
            
            {/* 기타 요청 */}
            <div className="bg-slate-900/50 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm text-slate-400 uppercase tracking-wider mb-4">기타 요청</h3>
              <textarea
                value={additionalNotes}
                onChange={(e) => setAdditionalNotes(e.target.value)}
                placeholder="추가 요청사항을 입력하세요..."
                className="w-full bg-slate-800/50 border border-slate-700 rounded-xl px-4 py-3 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 transition-colors resize-none h-20"
              />
            </div>
            
            {/* 버튼 */}
            <div className="flex gap-3">
              <button
                onClick={handleGenerate}
                className="flex-1 bg-slate-800 text-slate-300 py-4 rounded-xl font-medium hover:bg-slate-700 transition-colors"
              >
                스킵하고 바로 생성
              </button>
              <button
                onClick={handleGenerate}
                className="flex-1 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white py-4 rounded-xl font-medium hover:from-emerald-400 hover:to-emerald-500 transition-all flex items-center justify-center gap-2"
              >
                <Sparkles size={18} />
                설정 적용 후 생성
              </button>
            </div>
          </div>
        )}
        
        {/* 생성 중 */}
        {step === "generating" && (
          <div className="flex flex-col items-center justify-center py-20">
            <div className="w-20 h-20 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mb-6 animate-pulse">
              <Loader2 size={32} className="text-white animate-spin" />
            </div>
            <h2 className="text-xl font-bold mb-2">AI가 커리큘럼을 생성하고 있습니다</h2>
            <p className="text-slate-400">잠시만 기다려주세요...</p>
          </div>
        )}
        
        {/* 결과 화면 */}
        {step === "result" && (
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold">생성된 커리큘럼</h2>
                <p className="text-slate-400 text-sm">운동을 수정하거나 대체할 수 있습니다</p>
              </div>
              <button
                onClick={() => setStep("settings")}
                className="px-4 py-2 text-slate-400 hover:text-white transition-colors"
              >
                다시 설정
              </button>
            </div>
            
            <div className="space-y-3">
              {generatedCurriculum.map((exercise, index) => (
                <CurriculumCard
                  key={exercise.id}
                  exercise={exercise}
                  index={index}
                  onReplace={handleReplace}
                />
              ))}
            </div>
            
            <button
              onClick={handleConfirm}
              className="w-full bg-gradient-to-r from-emerald-500 to-emerald-600 text-white py-4 rounded-xl font-medium hover:from-emerald-400 hover:to-emerald-500 transition-all flex items-center justify-center gap-2"
            >
              <Check size={18} />
              커리큘럼 확정
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
