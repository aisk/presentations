#lang slideshow

(require slideshow/code)
(require slideshow/text)
(require pict/tree-layout)

(define (db-row content)
  (cc-superimpose
    (rectangle #:border-width 2 700 55)
    (small (t content))))

(slide
  (big (t "“常规”数据库简介"))
  (t "asaka@leancloud")
  (small (t "2016.12.28"))
  )

(slide
  #:title "如何实现一个简单的数据库？"
  (db-row "{objectId: 1, name: 'foo', age: 32}")
  (db-row "{objectId: 2, name: 'bar', age: 32}")
  (db-row "{objectId: 3, name: 'baz', age: 33}")
  (db-row "{objectId: 4, name: 'qux', age: 22}")
  (db-row "{objectId: 5, name: 'foo', age: 12}")
  (t "...")
  (db-row "{objectId: 9999, name: 'foo', age: 32}")
  (db-row "{objectId: 10000, name: 'foo', age: 32}")
  )

(slide
  (t "存储"))

(slide
  #:title "基于内存"
  (para "特性")
  (item "随机读写性能高")
  (para "优点")
  (item "高性能")
  (para "缺点")
  (item "持久化")
  (item "数据总量受内存大小限制")
  )

(slide
  #:title "磁盘"
  (para "特性")
  (item "随机读写性能插，顺序读写性能尚可")
  (para "优点")
  (item "数据总量不受内存大小限制")
  (item "持久化")
  (para "缺点")
  (item "性能")
  )

(slide
  #:title "磁盘 + 内存"
  (para "常见策略")
  (item "查询时，数据按 page 读入内存")
  (item "写入时，数据写入内存")
  (subitem "同时在磁盘记录日志（顺序读写）"
           "意外重启／断电，根据日志恢复内存数据")
  )

(slide
  #:title "启示"
  (item "不要在数据库中保存较大的数据")
  (subitem "导致 page 在内存与磁盘中换入／换出频繁")
  )

(slide
  (t "数据结构"))

(slide
  #:title "数组"
  (item "将数据按行依次存放于磁盘中")
  (para "优点")
  (item "新增数据性能好（O(1)）")
  (item "局部性原理")
  (subitem "找到数据后，即可将本条数据所有字段取出")
  (subitem "与上面介绍的 page 模型匹配")
  (para "缺点")
  (item "查询性能差（O(N)）")
  )

(slide
  (code "select * from users where age > 20")
  (item "遍历整个数据库表文件，找出符合条件的数据"))

(slide
  #:title "启示"
  (item "不要在数据库中保存较大的数据")
  (subitem "导致遍历速度降低")
  (item "需要查询多个条件的数据，必须带上 limit")
  (subitem "遍历过程中找到足够多的数据，即可中断遍历")
  (item "不要频繁增大单行数据大小")
  (subitem "可能会导致数据在磁盘上的位置的移动"
           "导致性能严重下降")
  )

(slide
  #:title "树"
  (naive-layered (tree-layout
                   #:pict (frame (t "7  16"))
                   (tree-edge #:edge-width 2 (tree-layout
                                               #:pict (frame (t "1  2  5  6"))))
                   (tree-edge #:edge-width 2 (tree-layout
                                               #:pict (frame (t "9  12"))))
                   (tree-edge #:edge-width 2 (tree-layout
                                               #:pict (frame (t "18  21"))))
                   )))

(slide
  #:title "树"
  (item "数据库常用 B tree 系列")
  (para "优点")
  (item "查询速度较快（O(logN)）")
  (para "缺点")
  (item "只能以一个字段作为查询条件")
  (item "插入数据时需要进行平衡")
  (subitem "平衡过程需要移动磁盘节点，性能比较低下")
  )

(slide
  #:title "数组 + 数"
  (item "使用数组保存完整数据")
  (item "允许在表的某个字段／复合字段上创建索引")
  (subitem "单个表允许多个索引")
  (subitem "索引数的每个节点保存一个字段的值"
           "加此字段在数组的位置")
  (subitem "索引相对数据正文，体积更小"
           "内存缓存命中率更高，换页情况较少")
  )

(slide
  #:title "启示"
  (item "合理使用索引，可以避免扫表")
  (para "数据量较大，查询频繁的表，一定要创建索引!")
  (item "建立索引过程相对较慢")
  (subitem "因此不能盲目在所有字段建立索引"
           "以免影响插入／更新性能")
  (subitem "对已有比较大量数据的字段表创建索引，会有巨大性能开销"
           "务必提前规划好索引，避免高峰时段创建索引")
  )

(slide
  #:title "没有银弹"
  (para "索引的局限性")
  (code "select * from users")
  (code "where age > 1")
  (code "and name = 'foo'")
  )

(slide
  (para "问题")
  (item "绝大部分数据库实现，一次查询中只使用一个索引")
  (item "如果对 age 和 name 都分别创建了索引，")
  (item "并且使用了age 索引")
  (subitem "与扫全表基本无异")
  )

(slide
  #:title "创建索引的原则"
  (item "只针对重复率较小的字段单独创建索引")
  (subitem "比如性别这种各占一半的字段，单独创建索引，"
           "如果命中索引，只能避免一半的扫全表开销")
  (item "根据情况，适当创建联合索引")
  )
