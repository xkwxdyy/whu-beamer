\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\RequirePackage{expl3}
\RequirePackage{xparse}
\ProvidesExplClass {whu-beamer}
  { 2023-09-16 } { v0.2 }
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

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
\RequirePackage { etoolbox }
\RequirePackage { graphicx }
\RequirePackage { xcolor }
\RequirePackage { fontspec }
\RequirePackage { xeCJK }
\RequirePackage { xeCJKfntef }
\RequirePackage { amsthm }
\RequirePackage { thmtools }

% beamer 设置
\usetheme[secheader]{Madrid}


% 个人信息接口

\keys_define:nn { whu-beamer / info }
  {
    advisor              .tl_set:N = \l__whubeamer_info_advisor_tl,
    research-fields      .tl_set:N = \l__whubeamer_info_research_fields_tl,
  }

\keys_set:nn { whu-beamer / info }
  {
    advisor         = 未知,
    research-fields = 未知,
  }
\keys_define:nn { whu-beamer }
  { info .meta:nn = { whu-beamer / info } {#1} }

\setbeamertemplate{title~page}
  {
    \vbox{}
    \vfill
    \begingroup
      \centering
      \begin{beamercolorbox}[sep=8pt,center,rounded=true,shadow=true]{title}
        \usebeamerfont{title}\inserttitle\par%
        \ifx\insertsubtitle\@empty%
        \else%
          \vskip0.25em%
          {\usebeamerfont{subtitle}\usebeamercolor[fg]{subtitle}\insertsubtitle\par}%
        \fi%     
      \end{beamercolorbox}%
      \vskip2em\par
      \begin{beamercolorbox}[sep=4pt,center]{author}
        \usebeamerfont{author}
        姓名：\insertauthor\\[0.5em]
        导师：\l__whubeamer_info_advisor_tl\\[0.5em]
        研究方向：\l__whubeamer_info_research_fields_tl
      \end{beamercolorbox}
      \vskip2em\par
      \begin{beamercolorbox}[sep=4pt,center]{institute}
        \usebeamerfont{institute}\insertinstitute
      \end{beamercolorbox}
      \begin{beamercolorbox}[sep=0pt,center]{date}
        \usebeamerfont{date}\insertdate
      \end{beamercolorbox}\vskip0.5em
      {\usebeamercolor[fg]{titlegraphic}\inserttitlegraphic\par}
    \endgroup
    \vfill
  }

% 致谢

\keys_define:nn { whu-beamer / acknowledgements }
  {
    color .tl_set:N = \l__whubeamer_acknowledgements_color_tl,
    color .initial:n = black
  }
\NewDocumentEnvironment { acknowledgements } { O{} +b }
  {
    \group_begin:
      \keys_set:nn { whu-beamer / acknowledgements } {#1}
      \begin{frame}
        \begin{center}
          \color{ \l__whubeamer_acknowledgements_color_tl }
          \Huge \bfseries
          #2
        \end{center}
      \end{frame}
    \group_end:
  }
  {}