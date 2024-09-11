import React from "react";
import {
    PlusIcon,
    XMarkIcon,
    UserGroupIcon,
    CloudArrowUpIcon,
    ShareIcon,
    ClockIcon,
  } from "@heroicons/react/24/solid";
  import {
    DocumentIcon,
    PhotoIcon,
    VideoCameraIcon,
    ChartBarIcon,
    CodeBracketIcon,
    GlobeAltIcon,
    PresentationChartLineIcon,
    ArchiveBoxIcon,
    BookOpenIcon,
    EnvelopeIcon,
    NewspaperIcon,
    PuzzlePieceIcon,
    RssIcon,
    ShoppingCartIcon,
    CalculatorIcon,
    ChatBubbleBottomCenterTextIcon,
    CurrencyDollarIcon,
    HeartIcon,
  } from "@heroicons/react/24/outline"; 

const FloatingFile = ({
  Icon,
  className,
}: {
  Icon: React.ElementType;
  className: string;
}) => (
  <div className={`absolute ${className} animate-float`}>
    <Icon className="h-8 w-8 sm:h-12 sm:w-12 text-white opacity-20" />
  </div>
);

const FloatingFilesDisplay = () => {
  return (
    <>
      <FloatingFile Icon={DocumentIcon} className="top-[10%] left-[5%]" />
      <FloatingFile Icon={PhotoIcon} className="top-[15%] right-[10%]" />
      <FloatingFile
        Icon={VideoCameraIcon}
        className="bottom-[15%] right-[12%]"
      />
      <FloatingFile Icon={ChartBarIcon} className="bottom-[10%] right-[28%]" />
      <FloatingFile Icon={CodeBracketIcon} className="top-[22%] left-[18%]" />
      <FloatingFile Icon={GlobeAltIcon} className="bottom-[25%] right-[20%]" />
      <FloatingFile
        Icon={PresentationChartLineIcon}
        className="top-[18%] left-[80%]"
      />
      <FloatingFile
        Icon={ArchiveBoxIcon}
        className="bottom-[22%] right-[75%]"
      />
      <FloatingFile Icon={BookOpenIcon} className="top-[85%] left-[15%]" />
      <FloatingFile Icon={EnvelopeIcon} className="top-[5%] right-[30%]" />
      <FloatingFile Icon={NewspaperIcon} className="top-[12%] left-[88%]" />
      <FloatingFile
        Icon={PuzzlePieceIcon}
        className="bottom-[8%] right-[85%]"
      />
      <FloatingFile Icon={RssIcon} className="top-[28%] left-[35%]" />
      <FloatingFile
        Icon={ShoppingCartIcon}
        className="bottom-[30%] right-[40%]"
      />
      <FloatingFile Icon={CalculatorIcon} className="top-[75%] left-[92%]" />
      <FloatingFile
        Icon={ChatBubbleBottomCenterTextIcon}
        className="bottom-[80%] right-[88%]"
      />
      <FloatingFile
        Icon={CurrencyDollarIcon}
        className="top-[90%] left-[40%]"
      />
      <FloatingFile Icon={HeartIcon} className="bottom-[85%] right-[45%]" />
      <FloatingFile Icon={VideoCameraIcon} className="bottom-[5%] left-[65%]" />
      <FloatingFile Icon={DocumentIcon} className="top-[82%] right-[72%]" />
      <FloatingFile Icon={PhotoIcon} className="bottom-[18%] left-[78%]" />
      <FloatingFile Icon={ChartBarIcon} className="bottom-[38%] left-[3%]" />
    </>
  );
};

export default FloatingFilesDisplay;
