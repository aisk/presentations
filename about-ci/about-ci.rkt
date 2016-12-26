#lang slideshow

(require slideshow/code)
(require slideshow/text)

(slide
  (big (t "持续集成与自动化测试／发布"))
  (t "asaka@leancloud")
  (small (t "2016.12.26"))
  )

(slide
  #:title "什么是持续集成"
  (para "严格意义上的持续集成")
  (item "在开发过程中")
  (item "持续性(不断)地"
        (item "每天")
        (item "每次提交"))
  (item "执行项目发布流程"
        (item "编译")
        (item "部署")
        (item "测试")
        (item "汇报结果"))
  )

(slide
  #:title "所需条件"
  (item "代码版本管理软件"
        (item "根据版本管理软件的版本号进行自动集成、归档")
        (item "可以使集成过程变得「可重试」"))
  (item "接近生产环境的 staging 环境")
  (item "自动化脚本"
        (item "进行编译／部署／测试的自动化脚本"))
  (item "执行持续集成的服务器")
  )

(slide
  #:title "常见的持续集成流程"
  (item "提交代码")
  (item "git hook 触发 CI 服务器")
  (item "自动编译，并执行单元测试／静态代码分析")
  (item "自动部署至 staging 环境")
  (item "自动运行集成测试")
  (item "运行测试")
  (item "汇报结果")
  )

(slide
  #:title "优点"
  (item "在开发过程中即执行集成流程，提早发现问题")
  (item "多人协作项目中，提早发现问题")
  (item "生产环境中发现问题之后"
        "可快速回滚到没有问题的版本")
  (item "自动化代码的便利性")
  (item "节省发布时间，降低发布流程的不可预测性")
  )

(slide
  #:title "缺点"
  (item "编写／维护自动化脚本／测试／环境"
        "增大了开发成本")
  (blank-line)
  (para (small (t "* 可以考虑适当减少流程，来降低成本")))
  )

(slide
  #:title "On LeanCloud"
  (para "基于 LeanCloud / 云引擎的一个持续集成流程")
  (item "功能开发")
  (item "基于 nosetest / mocha 编写单元测试用例")
  (item "在单元测试前使用脚本初始化测试数据")
  (item "提交代码，触发 CI")
  (item "执行单元测试／静态代码分析")
  )

(slide
  #:title "On LeanCloud"
  (para "基于 LeanCloud / 云引擎的一个持续集成流程")
  (item "将代码部署至与生产环境完全隔离的应用"
        (item "可使用云引擎 Rest API ／命令行工具部署指定版本到云引擎"))
  (item "执行集成测试脚本／手动进行集成测试")
  (item "汇报结果")
  )

(slide
  #:title "On LeanCloud"
  (para "基于 LeanCloud / 云引擎的一个持续集成流程")
  (item "手动触发发布流程")
  (item "编译／部署指定分支代码到生产环境")
  (item "执行集成／回归测试脚本，以及手动测试")
  )

(slide
  #:title "常见 CI 服务选择"
  (item "Jenkins"
        (item "功能强大，插件众多")
        (item "需要自己搭建")
        )
  (item "TravisCI / CircleCI"
        (item "第三方服务，闭源项目收费")
        (item "功能相对简单，主要用来做自动化测试")
        (item "访问国内服务比较慢")
        )
  (item "flow.ci"
        (item "TravisCI 的国内竞品"))
  )

(slide
  (big (t "其他团队是如何做持续集成的")))

(slide
  (big (t "F & Q")))
