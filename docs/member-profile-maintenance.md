# 成员科研介绍维护

成员从 [网站提交说明](https://metaindux.github.io/team/submit/)进入 [GitHub 成员资料表单](https://github.com/MetaIndux/MetaIndux.github.io/issues/new?template=member-profile.yml)，也可先使用 [可下载的填写模板](../downloads/member-profile-template.md)整理资料。

**GitHub Issue 的正文、附件和后续讨论本身公开。** 表单只收集供公开展示的资料，不是私密提交渠道。提交不会自动改写成员文件或发布网站；维护者核对、修改并推送代码后，才进入网站构建与部署流程。

## 核对提交者与内容

1. 根据团队已有记录、已知联系方式或官方个人主页，人工确认提交者身份及其对应成员。不能仅凭 GitHub 昵称认定身份。
2. 对照现有成员页，核对中文姓名、英文论文署名、单位、当前身份以及新增内容。学生与毕业成员还应核对博士／硕士阶段、该阶段入学年份、是否已毕业；在读时核对当前年级，已毕业时核对实际毕业年份。必要的确认通过团队已有联系方式完成，不要求成员在公开 Issue 中上传证件或其他敏感证明。
3. 核对代表工作的作者、标题、年份、发表渠道和链接。已发表、已录用、预印本与投稿中应明确区分；同名作者的成果不能仅凭姓名归属。
4. 个人贡献采用成员确认的具体描述，不从作者顺序推断，也不把团队整体成果改写成个人独立成果。对尚未公开的项目，只使用允许公开的内容。
5. 确认成员愿意公开相关邮箱、照片与外链；删除填写提示和占位示例后再录入页面。

## 更新现有成员文件与照片

先在 `_members/` 中找到对应成员的现有 Markdown 文件。文件名通常决定成员页的 slug，例如 `_members/haiteng-wang.md` 对应 `/members/haiteng-wang.html`。更新资料时不要另建重复成员，也不要改名造成旧链接失效。

保留现有文件名，以及 front matter 中已有的 `slug`（如有）、`name`、`role`、`group`、`order`。不要把表单内容整段覆盖到 front matter。身份分类等字段如确需变更，应作为单独核实的调整处理。

毕业成员继续保留原 `role`、`group`、`order` 和 slug，通过新增或更新 `status: alumni` 归入团队页最下方的毕业成员区域；不要为了移到页底而改名、换分组或创建重复文件。

`aliases` 保存英文论文署名，关系到相关论文匹配；保留已有有效别名，新增别名前确认其确属本人。`description` 和 `affiliation` 只在资料核实后按需要更新。已有 `profile_content` 等配置也应保留。

新照片从提交附件中下载到 `images/people/`，使用清晰稳定的文件名，并在成员文件中设置对应的 `image: /images/people/文件名.jpg` 或 `.png`。建议 JPG/PNG、至少 600×600 像素、3 MB 以内；检查朝向和裁剪效果，不使用 Issue 附件地址作为成员页的长期头像地址。没有新照片时保留现有图片路径，不删除仍被其他文件引用的照片。

**保留已有 PI 长简介。** 特别是 `_members/lei-ren.md` 中已经核实的完整介绍、成果、学术服务和资料来源，不应因统一模板而缩减或替换。其他已有丰富正文的成员同样以补充、纠错为主。下面的四节结构适用于新增科研介绍或原本没有正文的成员。

## 培养阶段、年级与毕业状态

学生与毕业成员提交资料时，博士／硕士阶段、该阶段入学年份、是否已毕业为必填信息。在读成员还应填写当前年级，已毕业成员还应填写实际毕业年份。教师、博士后等不适用这些学生信息的身份可以注明“不适用”，录入时省略相应字段。

将核实后的信息写入现有成员文件的 YAML front matter：

| 字段 | 格式与填写条件 | 维护说明 |
| --- | --- | --- |
| `degree` | `phd` 或 `master` | 对应博士或硕士阶段。可省略并由已有博士／硕士 `role` 推断；本次收到明确资料时优先显式记录。 |
| `status` | `active` 或 `alumni` | 默认 `active`；确认毕业后设为 `alumni`，不改变原 `role`、`group`、`order` 或 slug。 |
| `enrollment_year` | 四位数字年份，不加引号 | 学生与毕业成员填写该培养阶段的入学年份，不填本科入学年份来代替。 |
| `study_year` | 中文字符串，如 `博士三年级` | 在读时填写；由成员确认、维护者手动更新，不根据入学年份自动推算。毕业资料不填写当前在读年级。 |
| `graduation_year` | 四位数字年份，不加引号 | 仅已毕业时填写实际毕业年份；在读时省略，不填写预计毕业年份。 |

`YYYY` 只是年份格式说明，不能作为字面值写入成员文件。尚未确认的信息保持待核实，不填猜测值。**不要从姓名、照片、论文年份或外观判断成员是否毕业或现在读几年级，也不要用“当前年份减入学年份”推算年级。** 缺少必要资料时，应向成员确认后再补入；不能把系统默认 `active` 当作已经核实的在读证明。

页面兼容已有 `group: alumni`、`group: phd-alumni`、`group: master-alumni`，以及 `role: phd-alumni`、`role: master-alumni` 的毕业标记。维护旧资料时保留这些已有分类；新确认的毕业变更统一使用 `status: alumni`，不为迁移格式而随意重写旧分组。

毕业成员在团队页最下方集中展示，个人页面地址与原有论文关联保持不变。每次入学、学年变化或毕业信息更新后，都应人工核对当前年级与展示状态；系统不会随日期自动升级年级。

## 正文采用四节 Markdown

在 YAML front matter 结束标记之后写正文。沿用成员页的容器，可以使用以下结构：

```markdown
<div class="member-profile" markdown="1">

## 个人简介

填写核实后的身份、研究问题、方法与应用场景，建议 100–200 字。

## 研究方向

- 方向名称：具体研究问题。
- 方向名称：具体研究问题。
- 方向名称：具体研究问题。

## 代表工作

### 工作标题

作者、年份、发表渠道与当前状态。

工作简介：说明问题、方法和有依据的结果。

本人贡献：写明经成员确认的实际工作。

[论文或项目](真实链接) · [代码或数据](真实链接)

## 公开联系方式

填写成员同意公开的学术邮箱及必要说明。

</div>
```

研究方向建议 3–5 项，代表工作建议 2–5 项；没有公开成果时可以注明暂无，不补造条目。删除不适用的链接和占位文字。模板中“真实链接”等提示不能直接发布。

学术外链可以继续放在现有 front matter 的 `links` 中，沿用仓库已有的键与格式。比如 `external` 或 `home-page` 使用完整 URL；`google-scholar` 和 `orcid` 沿用已有成员文件中的账号 ID 格式。具体类型与地址规则可核对 `_data/types.yaml`。不要因为新增正文而删除已经核实的外链。

布局会按姓名和 `aliases` 自动展示相关论文；人工撰写的“代表工作”用于说明精选成果和个人贡献，不需要复制全部论文目录。遇到自动匹配错误时应核对论文数据与别名，不能通过修改姓名来掩盖问题。

个人页桌面端采用身份侧栏与正文两栏，手机端为单列；头像来自 `image`，身份来自 `description`，学习或毕业信息来自上表字段。成员公开邮箱可写入 `links.email`；没有个人邮箱时，联系区域明确展示团队邮箱，不将其标为个人邮箱。

## 本地检查与部署

本仓库使用 Ruby 3.3、Bundler 和 Jekyll。首次准备环境时运行 `bundle install`。在仓库根目录构建并执行现有检查脚本。

PowerShell：

```powershell
$env:JEKYLL_ENV = "production"
bundle exec jekyll build
bundle exec ruby scripts/check-site.rb
bundle exec ruby scripts/check-indexnow.rb
bundle exec ruby scripts/check-members.rb
git diff --check
```

Bash：

```sh
JEKYLL_ENV=production bundle exec jekyll build
bundle exec ruby scripts/check-site.rb
bundle exec ruby scripts/check-indexnow.rb
bundle exec ruby scripts/check-members.rb
git diff --check
```

检查生成的 `_site/members/` 中对应页面，确认四节正文、中文与英文姓名、照片和外链显示正确，且没有重复标题、占位文本或意外公开的信息。同时检查 `_site/team/index.html`：博士／硕士阶段、入学年份及手动填写的年级应与资料一致；已毕业成员只出现在页底的毕业成员区域，不与在读成员重复展示。只修改 Markdown 也应完成一次构建，确认 front matter 和 Liquid 渲染正常。

完成复核后提交成员文件及必要照片，通过仓库正常流程合并或推送到 `main`。不要提交生成目录 `_site/`，也不要手动把源文件推到 `gh-pages`。

`on-push.yaml` 会调用 `build-site.yaml`：构建并运行检查，成功后将生成站点部署到 Pages 分支。随后确认 GitHub Pages 部署成功，再打开正式成员网址检查新内容和图片。部署失败时先查看 Actions 日志，修复后重新构建，不将失败的构建视为已发布。

当前 `on-pages.yaml` 会在成功部署后运行 IndexNow 通知流程。它通知搜索引擎网页发生变化，不等于已收录或排名提高；成员资料提交本身也不会触发该流程。搜索维护细节见 [搜索收录维护](search-indexing.md)。

## 模板参考

填写结构参考了官方主页中简介、研究兴趣、精选成果和联系方式的组织方式：

- [清华大学计算机系朱军主页](https://www.cs.tsinghua.edu.cn/info/1121/3551.htm)：研究领域、研究概况与学术成果分开呈现。
- [MIT CSAIL Daniela Rus 主页](https://www.csail.mit.edu/person/daniela-rus)：头像、简短介绍、方向标签与精选论文集中呈现。
- [Stanford Fei-Fei Li 主页](https://profiles.stanford.edu/fei-fei-li)：个人简介、研究兴趣、成果及外部链接分别组织。

本项目的字数、条目数量与照片尺寸是维护建议，不是上述学校的统一规范。参考页面只用于组织结构，不复制其他研究人员的履历、评价或成果。
