---
title: 提交成员资料
seo_title: 提交照片与个人科研介绍
description: MetaIndux 团队成员照片与科研介绍提交入口，提供个人简介、研究方向、代表工作和公开联系方式的填写模板。
---

{% capture profile_form_url %}https://github.com/{{ site.repository }}/issues/new?template=member-profile.yml{% endcapture %}

<div class="content-page profile-submission-page">
  <div class="page-heading">
    <p class="submission-breadcrumb"><a href="{{ '/team/' | relative_url }}">团队成员</a> / 提交资料</p>
    <h1>提交照片与个人科研介绍 <span lang="en">Member Profile Submission</span></h1>
    <p>团队成员可在这里提交或更新照片、个人介绍与科研成果。资料核对后，由网站维护者更新到个人主页。</p>
  </div>

  <div class="submission-actions">
    <a class="button" href="{{ profile_form_url | strip | xml_escape }}">填写资料并上传照片</a>
    <a class="button" data-style="bare" href="{{ '/downloads/member-profile-template.md' | relative_url }}" download>下载介绍模板（Markdown）</a>
  </div>
  <p class="submission-note">在线提交需要登录 GitHub，无需仓库写权限。表单和照片在公开仓库中可见，请只填写愿意公开的资料。</p>

  <h2>如何提交</h2>
  <ol class="submission-steps">
    <li>点击“填写资料并上传照片”，登录自己的 GitHub 账号。</li>
    <li>按表单填写姓名、身份，以及博士或硕士阶段、入学年份、当前年级、是否已毕业和毕业年份。已有个人主页请附上链接。</li>
    <li>在“个人照片”一栏拖入、粘贴或选择照片，等待图片链接生成；只更新介绍时可填写“沿用现有照片”。</li>
    <li>核对后点击 <span lang="en">Submit new issue</span>。网站维护者确认资料后更新主页；之后补充资料可在同一提交中回复。</li>
  </ol>

  <h2 id="template">介绍模板</h2>
  <p>在读成员请写明“博士几年级”或“硕士几年级”；已毕业成员请填写实际毕业年份。确认毕业的成员会集中展示在团队页最下方，原个人主页链接继续保留。教师、研究人员等可选“不适用”。</p>
  <p>建议使用下面的结构。请填写本人实际研究内容，不必把团队的所有研究方向都列为个人方向。</p>
  <div class="submission-outline">
    <article>
      <h3>01 个人简介</h3>
      <p>建议100–200字，介绍当前身份与所属单位、培养阶段及年级、研究问题、采用的方法和应用场景。其他教育经历、奖项及学术服务可选。</p>
      <p class="submission-example">填写句式：我目前在【学校及学院】从事【研究问题】研究，采用【方法】，关注【应用场景】。近期参与【真实研究主题】，负责【本人工作】。</p>
    </article>
    <article>
      <h3>02 研究方向</h3>
      <p>建议3–5项，每项写一个方向名称，并用一句话说明具体研究内容。</p>
      <p class="submission-example">填写句式：【方向名称】：研究【具体问题】，面向【任务或应用场景】。</p>
    </article>
    <article>
      <h3>03 代表工作</h3>
      <p>建议2–5项，论文、公开项目、软件和数据集均可。每项写明标题、作者或参与者、年份、发表渠道与状态、工作简介、本人贡献及原文链接。</p>
      <p>请明确区分已发表论文、预印本和已录用成果；本人贡献由本人填写。暂无公开成果可写“暂无”。</p>
    </article>
    <article>
      <h3>04 联系方式</h3>
      <p>填写愿意公开的学术邮箱，可补充个人主页、Google Scholar、ORCID 或 GitHub。没有或不希望公开的项目可以留空。</p>
    </article>
  </div>

  <h2>照片建议</h2>
  <p>请使用清晰的本人头像，建议为JPG或PNG、600×600像素以上、3MB以内。方形照片更适合团队页面，头肩完整并适当留白，避免文字、水印或多人合影。暂无照片可选择默认头像。</p>

  <div class="submission-help">
    <h2>其他提交方式</h2>
    <p>没有 GitHub 账号的成员，也可下载模板填写后，将资料与照片发送至团队邮箱：<a href="mailto:{{ site.links.email | xml_escape }}">{{ site.links.email }}</a>。</p>
    <p><a href="{{ '/team/' | relative_url }}">返回团队成员</a></p>
  </div>
</div>
