\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\RequirePackage{expl3}
\RequirePackage{xparse}
\ProvidesExplClass {whu-beamer}
  { 2022-03-16 } { v0.1a }
  { Beamer template for Whuhan University }

% 检查 LaTeX2e kernel 版本
\msg_new:nnn { whu-beamer } { latex-too-old }
  { TeX~ Live~ 2020~ or~ later~ version~ is~ required~ to~ compile~ this~ document. }
\@ifl@t@r \fmtversion { 2020/02/02 }
  { }
  { \msg_fatal:nn { whu-beamer } { latex-too-old } }

% 判断引擎
\msg_new:nnn { whu-beamer } { unsupported-engine }
  {
    The~ whu-beamer~ class~ requires~ either~ XeTeX~ or~ LuaTeX. \\\\
    "#1"~ is~ not~ supported~ at~ present.~ You~ must~ change \\
    your~ typesetting~ engine~ to~ "xelatex"~ or~ "lualatex".
  }
\sys_if_engine_xetex:F
  {
    \sys_if_engine_luatex:F
      {
        \msg_fatal:nnx { whu-beamer } { unsupported-engine }
          { \c_sys_engine_str }
      }
  }


% 用户设置命令
\NewDocumentCommand \whubeamersetup { m }
  { \keys_set:nn { whu-beamer } {#1} }

% 处理文档类选项
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { ctexbeamer } }
\ProcessOptions*

\RequirePackage { filehook }
\AtEndOfPackageFile* { fontspec }
  { \msg_redirect_name:nnn { fontspec } { no-script } { none } }
\AtEndOfPackageFile* { xeCJK }
  {
    \msg_redirect_name:nnn { xeCJK } { CJKfamily-redef } { none }
    \defaultCJKfontfeatures
      {
        Script  = CJK,
        Mapping = fullwidth-stop ,
      }
  }

\LoadClass{ ctexbeamer }




% 主题
\usetheme{Berlin}
\useoutertheme
  [
    height = 0.1\textwidth,
    width  = 0.15\textwidth,
    hideothersubsections,
  ]
  {sidebar}
\usecolortheme{whale}               % Outer color themes, 其他选择: whale, seahorse, dolphin
\usecolortheme{orchid}              % Inner color themes, 其他选择: lily, orchid
\useinnertheme[shadow]{rounded}     % 对 box 的设置: 圆角、有阴影.
\logo{\includegraphics[width = 1cm]{./logo/whu-logo.png}}
% 颜色设置
\setbeamercolor{sidebar}{bg = blue!50}   % sidebar的颜色, 50%的蓝色.
\setbeamertemplate     % 背景色, 上25%的蓝, 过渡到下白.
  {background~canvas}
  [vertical~shading]
  [
    bottom = white,
    top    = structure.fg!25
  ] 

% 去掉导航条
\setbeamertemplate{navigation~symbols}{}   %% 去掉页面下方默认的导航条.
% 重定义footline
\setbeamercolor{footline}{bg = blue!50 , fg = white}
\setbeamertemplate{footline}
  {
    \begin{beamercolorbox}[sep = 4pt]{footline}
      \bfseries
      \l__whubeamer_info_type_tl
      \hfill
      \insertinstitute
    \end{beamercolorbox}
  }


% beamer字体设置
% \usefonttheme{serif}  % 字体


% 要求 ctex v2.4.9 2017-04-01 或更高的版本。
\msg_new:nnn { whu-beamer } { require-package-version }
  { The~ package~ "#1"~ is~ required. }

\@ifclasslater { ctexbeamer } { 2017/04/01 }
  { }
  {
    \msg_fatal:nnn { whu-beamer } { require-package-version }
      { ctex~ v2.4.9~ 2017-04-01 }
  }


% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
\RequirePackage { etoolbox }
\RequirePackage { graphicx }
\RequirePackage { xcolor }
\RequirePackage { fontspec }
\RequirePackage { xeCJK }
\RequirePackage { xeCJKfntef }
\RequirePackage { lastpage }
\RequirePackage { biblatex }
\RequirePackage { amsthm }
\RequirePackage { thmtools }
\RequirePackage { tikzpagenodes }


% 处理参考文献

\keys_define:nn { whu-beamer / bib }
  {
    resource  .clist_set:N  = \l__whubeamer_bib_resource_clist,
    bibintoc  .bool_set:N   = \l__whubeamer_bib_bibintoc_bool,
    bibintoc  .initial:n    = true,
    title     .tl_set:N     = \l__whubeamer_bib_title_tl,
    title     .initial:n    = { Bibliography },
  }
\keys_define:nn { whu-beamer }
  { bib .meta:nn = { whu-beamer / bib } {#1} }

\ctex_at_end_preamble:n
  {  
    \PassOptionsToPackage 
      {
        backend = biber, 
        natbib,
        style = gb7714-2015
      }
      { biblatex }
    \exp_args:NV \addbibresource \l__whubeamer_bib_resource_clist
    \bool_if:NT \l__whubeamer_bib_bibintoc_bool
      {
        \cs_set_eq:NN \__xdyy_printbibliography_old \printbibliography
        \cs_new:Npn \__whubeamer_printbibliography:n #1 
          {
            \__xdyy_printbibliography_old[ #1 ] 
          }
        \RenewDocumentCommand { \printbibliography } { O{} } 
          {
            \__whubeamer_printbibliography:n { heading = bibintoc, title = { \tl_use:N \l__whubeamer_bib_title_tl }, #1 }
          }
      }
  }





% 由于 mathtools 需要在 unicode-math 前载入，所以推迟载入 unicode-math
\AtBeginOfPackageFile* { siunitx }
  { \RequirePackage { unicode-math } }
\AtEndPreamble
  { \RequirePackage { unicode-math } }


% 对冲突的宏包报错。
\msg_new:nnn { whu-beamer } { package-conflict }
  { The~ "#2"~ package~ is~ incompatible~ with~ "#1". }

\cs_new:Npn \whubeamer_package_conflict:nn #1#2
  {
    \AtEndOfPackageFile* {#1}
      {
        \AtBeginOfPackageFile* {#2}
          { \msg_error:nnnn { whu-beamer } { package-conflict } {#1} {#2} }
      }
  }

\whubeamer_package_conflict:nn { unicode-math } { amscd }
% \whubeamer_package_conflict:nn { unicode-math } { amsfonts }
% \whubeamer_package_conflict:nn { unicode-math } { amssymb }
\whubeamer_package_conflict:nn { unicode-math } { bbm }
\whubeamer_package_conflict:nn { unicode-math } { bm }
\whubeamer_package_conflict:nn { unicode-math } { eucal }
\whubeamer_package_conflict:nn { unicode-math } { eufrak }
\whubeamer_package_conflict:nn { unicode-math } { mathrsfs }
\whubeamer_package_conflict:nn { unicode-math } { newtxmath }
\whubeamer_package_conflict:nn { unicode-math } { upgreek }

\whubeamer_package_conflict:nn { enumitem } { paralist }


\ctex_at_end_preamble:n
  {
    \RequirePackage { hyperref }
    \hypersetup
      {
        bookmarksnumbered = true,
        psdextra          = true,
        unicode           = true,
        pdftitle    = \l__whubeamer_info_title_tl,
        pdfauthor   = \l__whubeamer_info_author_tl,
        colorlinks = true,
      }
    \exp_args:NV \hypersetup \g__whubeamer_to_hyperref_clist
    \whubeamer_allow_url_break:
  }

% 设置hyperref
\clist_new:N \g__whubeamer_to_hyperref_clist

\cs_new_protected:Npn \whubeamer_hyperref_setup:n #1
  { \clist_gput_right:Nn \g__whubeamer_to_hyperref_clist {#1} }
\cs_new_protected:Npn \__whubeamer_define_hyperlink_color:nnn #1#2#3
  {
    \definecolorset { HTML } { whubeamer@ } { }
      { link, #1; url, #2; cite, #3 }
  }
\cs_new:Npn \__whubeamer_set_hyperlink_color_key:n #1
  {
    \__whubeamer_define_hyperlink_color:nnn
      { \clist_item:nn {#1} {2} }
      { \clist_item:nn {#1} {3} }
      { \clist_item:nn {#1} {4} }
    \whubeamer_hyperref_setup:n
      {
        linkcolor = whubeamer@link, linkbordercolor = whubeamer@link,
        urlcolor  = whubeamer@url,  urlbordercolor  = whubeamer@url,
        citecolor = whubeamer@cite, citebordercolor = whubeamer@cite
      }
  }


% 直接用fduthesis修改颜色的做法会出问题（可能是一体性强）
% 稍微做点修改
\str_new:N \l__whubeamer_hyperref_color_str

\cs_new:Nn \__whubeamer_hyperref_color_set:
  {
    \str_case:VnF \l__whubeamer_hyperref_color_str
      {
        { autumn }{ \__whubeamer_set_hyperlink_color_key:n { autumn,    D70000, D75F00, AF8700 } }
        { business }{ \__whubeamer_set_hyperlink_color_key:n { business,  D14542, 295497, 1F6E43 }} 
        { classic }{ \__whubeamer_set_hyperlink_color_key:n { classic,   FF0000, 0000FF, 00FF00 } }
        { default }{ \__whubeamer_set_hyperlink_color_key:n { default,   990000, 0000B2, 007F00 } }
        { elegant }{ \__whubeamer_set_hyperlink_color_key:n { elegant,   961212, C31818, 9B764F } }
        { fantasy }{ \__whubeamer_set_hyperlink_color_key:n { fantasy,   FF4A19, FF3F94, 934BA1 } }
        { material }{ \__whubeamer_set_hyperlink_color_key:n { material,  E91E63, 009688, 4CAF50 } }
        { science }{ \__whubeamer_set_hyperlink_color_key:n { science,   CA0619, 389F9D, FF8920 } }
        { summer }{ \__whubeamer_set_hyperlink_color_key:n { summer,    00AFAF, 5F5FAF, 5F8700 } }
        { graylevel }{ \__whubeamer_set_hyperlink_color_key:n { graylevel, 616161, 616161, 616161 } }
        { prl }{ \__whubeamer_set_hyperlink_color_key:n { prl,       2D3092, 2D3092, 2D3092 } }
      }{\fail}
  }
\keys_define:nn { whu-beamer / hyperref }
  {
    hyperlink-color .code:n = 
      {
        \str_set:Nn \l__whubeamer_hyperref_color_str {#1}
        \__whubeamer_hyperref_color_set:
      },
    hyperlink-color .value_required:n = true,
    hyperlink-color .initial:n = prl,
  }

\keys_define:nn { whu-beamer }
  { hyperref .meta:nn = { whu-beamer / hyperref } {#1} }


% 允许url断行，来自fduthesis
\cs_new:Npn \whubeamer_allow_url_break:
  {
    \cs_new:Npn \__whubeamer_add_url_break_points:
      { \tl_map_function:NN \c__whubeamer_url_break_points_tl \do }
    \__whubeamer_appto_cmd:Nn \UrlBreaks
      { \UrlOrds \__whubeamer_add_url_break_points: }
  }
\tl_const:Nn \c__whubeamer_url_break_points_tl
  {
    abcdefghijklmnopqrstuvwxyz
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    0123456789
  }
\cs_new_protected:Npn \__whubeamer_appto_cmd:Nn #1#2
  {
    \ctex_appto_cmd:NnnTF #1 { } {#2}
      { } { \ctex_patch_failure:N #1 }
  }

% 个人信息接口

\keys_define:nn { whu-beamer / info }
  {
    author               .tl_set:N = \l__whubeamer_info_author_tl,
    title                .tl_set:N = \l__whubeamer_info_title_tl,
    date                 .tl_set:N = \l__whubeamer_info_date_tl,
    advisor              .tl_set:N = \l__whubeamer_info_advisor_tl,
    research-fields      .tl_set:N = \l__whubeamer_info_research_fields_tl,
    type                 .tl_set:N = \l__whubeamer_info_type_tl,
  }

\keys_define:nn { whu-beamer }
  { info .meta:nn = { whu-beamer / info } {#1} }

\title
  {
    \bfseries \tl_use:N \l__whubeamer_info_title_tl
  }

\author
  {
    \tl_use:N \l__whubeamer_info_author_tl
  }

\date
  {
    \tl_use:N \l__whubeamer_info_date_tl 
  }

\institute {武汉大学\quad 数学与统计学院}

% 重改标题页
\setbeamertemplate{title~page}
  {
    \begin{centering}
      % \begin{beamercolorbox}[sep = 8pt, center] {institute}
      %   \usebeamerfont{institute}\insertinstitute
      % \end{beamercolorbox}
      % title
      \begin{beamercolorbox}[sep = 6pt, center, shadow, rounded = true] {title}
        \usebeamerfont{title}\inserttitle\par%
        \ifx\insertsubtitle\@empty%
        \else%
          \vskip0.25em%
          {\usebeamerfont{subtitle}\usebeamercolor[fg]{subtitle}\insertsubtitle\par}%
        \fi%     
      \end{beamercolorbox}%
      \vskip2em \par
      \begin{center}
        \begin{tabular}{ll}
          姓名： & \l__whubeamer_info_author_tl   \\
          导师： & \l__whubeamer_info_advisor_tl  \\
          方向： & \l__whubeamer_info_research_fields_tl \\
        \end{tabular}
      \end{center}
      \par
      % 日期
      \begin{beamercolorbox}[sep = 8pt, center] {date}
        \usebeamerfont{date}
        \insertdate
      \end{beamercolorbox}
    \end{centering}
  }


% 字体

% 西文字体使用 New Computer Modern
\setmainfont { NewCM10 }
  [
    Extension      = .otf ,
    UprightFont    = *-Book ,
    BoldFont       = *-Bold ,
    ItalicFont     = *-BookItalic ,
    BoldItalicFont = *-BoldItalic ,
  ]
\setsansfont { NewCMSans10 }
  [
    Extension         = .otf ,
    UprightFont       = *-Book ,
    BoldFont          = *-Bold ,
    ItalicFont        = *-BookOblique ,
    BoldItalicFont    = *-BoldOblique ,
  ]
\setmonofont { NewCMMono10 }
  [
    Extension           = .otf ,
    UprightFont         = *-Book ,
    ItalicFont          = *-BookItalic ,
    BoldFont            = *-Bold ,
    BoldItalicFont      = *-BoldOblique ,
  ]

% 数学字体

% 按照国标样式配置 unicode-math

\tl_new:N \l__whubeamer_save_leq_tl
\tl_new:N \l__whubeamer_save_geq_tl
\AtEndOfPackageFile* { unicode-math }
  {
    \unimathsetup
      {
        math-style = ISO ,
        bold-style = ISO ,
        partial    = upright ,
      }
    \AtBeginDocument
      {
        \tl_set_eq:NN \leq \l__whubeamer_save_leq_tl
        \tl_set_eq:NN \geq \l__whubeamer_save_geq_tl
        \tl_set_eq:NN \leq \leqslant
        \tl_set_eq:NN \geq \geqslant
      }
    \cs_set_protected:Npn \mathellipsis { \mathinner { \unicodecdots } }
  }

\AtEndOfPackageFile* { unicode-math }
  {
    \setmathfont { NewCMMath-Book }
      [
        Extension    = .otf ,
        StylisticSet = 2 ,
      ]
    \setmathfont { NewCMMath-Book }
      [
        Extension    = .otf ,
        StylisticSet = 1 ,
        range        = { scr , bfscr } ,
      ]
    \setmathrm { NewCM10 }
      [
        Extension      = .otf ,
        UprightFont    = *-Book ,
        BoldFont       = *-Bold ,
        ItalicFont     = *-BookItalic ,
        BoldItalicFont = *-BoldItalic ,
      ]
    \setmathsf { NewCMSans10 }
      [
        Extension         = .otf ,
        UprightFont       = *-Book ,
        BoldFont          = *-Bold ,
        ItalicFont        = *-BookOblique ,
        BoldItalicFont    = *-BoldOblique ,
      ]
    \setmathtt { NewCMMono10 }
      [
        Extension           = .otf ,
        UprightFont         = *-Book ,
        ItalicFont          = *-BookItalic ,
        BoldFont            = *-Bold ,
        BoldItalicFont      = *-BoldOblique ,
      ]
  }


% 中文字体

% 在 ctex 的字体配置的基础上进行一些修改
% 将苹方和微软雅黑分别替换为华文黑体和中易黑体
\str_if_eq:onTF { \g__ctex_fontset_tl } { mac }
  {
    \setCJKsansfont { Heiti~ SC~ Light } [ BoldFont = Heiti~ SC~ Medium ]
  }
  {
    \str_if_eq:onT { \g__ctex_fontset_tl } { windows }
      { \setCJKsansfont { SimHei } }
  }

% 罗马数字使用中文字体
\xeCJKDeclareCharClass { CJK } { "2160 -> "217F }
% 带圈数字
\xeCJKDeclareCharClass { CJK } { "2460 -> "2473 }


% 如果有内容较高（如分式）使得行间距小于 0.5em，则将其增加至 0.5em。
\dim_set:Nn \lineskiplimit { .5em }
\skip_set:Nn \lineskip { .5em }



% unicode-math 的配置

% 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
\AtEndOfPackageFile* { unicode-math }
  {
    \NewDocumentCommand \bm { m } { { \symbfit { ##1 } } }
    \RenewDocumentCommand \boldsymbol { m } { { \symbfit { ##1 } } }
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    % \NewDocumentCommand \square { } { \mdlgwhtsquare }
    % \NewDocumentCommand \blacksquare { } { \mdlgblksquare }
    \AtBeginDocument
      { \RenewDocumentCommand \checkmark { } { \ensuremath{ ✓ } } }
  }


% 定义定理环境
\declaretheoremstyle
  [
    spaceabove = 6pt,
    spacebelow = 6pt,
    headfont = \normalfont\bfseries,
    notefont = \mdseries, 
    notebraces = {(}{)},
    bodyfont = \normalfont,
    % bodyfont = \itshape,
    headpunct = {},
    postheadspace = 1em,
  ]
  { withcounterstyle }


\cs_new:Npn \__whubeamer_declare_theorem_with_counter:n #1
  {
    \declaretheorem
      [
        style = withcounterstyle,
        name =  \clist_item:nn {#1} {1} ,
        refname = \clist_item:nn {#1} {2} ,
        within = \clist_item:nn {#1} {3} ,
      ]
      { \clist_item:nn {#1} {4} }
  }
\clist_map_function:nN
  {
    % { 定义, 定义, section, definition },
    % { 定理, 定理, section, theorem },
    % { 例, 例, section, example },
    { 性质, 性质, section, property },
    { 命题, 命题, section, proposition },
    % { 推论, 推论, section, corollary },
    % { 引理, 引理, section, lemma },
    { 公理, 公理, section, axiom },
    { 反例, 反例, section, antiexample },
    { 猜想, 猜想, section, conjecture },
    { 问题, 问题, section, question },
    { 断言, 断言, section, claim }
  }
  \__whubeamer_declare_theorem_with_counter:n



% 致谢
% 由于使用了 plain 之后还是会受到 sidebar 的影响
% 导致内容偏右，所以用 tikz 处理了一下

\keys_define:nn { whu-beamer / acknowledgements }
  {
    color .tl_set:N = \l__whubeamer_acknowledgements_color_tl,
    color .initial:n = black
  }
\NewDocumentEnvironment { acknowledgements } { O{} +b }
  {
    \group_begin:
      \keys_set:nn { whu-beamer / acknowledgements } {#1}
      \begin{frame}[plain]
        \begin{tikzpicture}[remember~picture, overlay]
          \node at (current~page.center)
            {
              \begin{minipage}{ \textwidth }
                \begin{center}
                  \color{ \l__whubeamer_acknowledgements_color_tl }
                  \Huge \bfseries
                  #2
                \end{center}
              \end{minipage}
            };
        \end{tikzpicture}
      \end{frame}
    \group_end:
  }
  {}