
### 在微服务中创建一个search服务提供者

##### 添加依赖==spring-boot-starter-data-solr==

##### bootstrap添加solr配置

```
spring:
  data:
    solr:
      host:http://192.168.xxx.xxx:xxxx/solr
```

##### 项目中添加mapper和mapper.xml

##### 创建一个实体类，根据字段创建属性

```
public class SearchResult implements Serializable{
    ....
}
```


##### 创建一个接口

```
public interface SearchService{
    public List<Sear> search(Strin query,int page,int row);
}
```
##### 实现接口


```
public class SearchServiceImpl implements SearchService{
    private static final String SOLR_COLLECTION="ik_core"
    
    @Autowired
    private SolrClient solrclient;
    
    @Override
    public List<SearchResult> search(String query,int page,int row){
        
        List<SearchResult> results= new ArrayList();
        
        //新建查询对象
        SolrQuery solrQuery = new SolrQuery();
        
        //设置查询条件
        solrQuery.setQuery(query);
        
        //设置分页
        solrQuery.setStart((page - 1) * row);
        solrQuery.setRows(row);
        
        //设置查询域
        solrQuery.set("df","article_keywords");
        
        //设置高亮显示
        solrQuery.setHighlight(true);
        solrQuery.addHighlightFied("article_title");
        solrQuery.setHighlightSimplePre("<span style='color:red'>");
        solrQuery.setHighlightPost("</span>")
        
        QueryResponse response = solrClient.query(SOLR_COLLECTION,solrQuery);
        
        SolrDocumentList list = response.getResult();
        Map<String,Map<String,List<String>>> highlighting = response.getHighlighting();
        
        for(SolrDocument document : lost){
            SearchResult result = new SearchResult();
            
            result.setId((Long)document.get("id"));
            result.setArticle_url((String)document.get("article_url"));
            result.setArticle_source((String)document.get("article_source"));
            result.setArticle_introduction((String)document.get("article_introducation"));
            result.setArticle_cover((String)document.get("article_cover"));
            
            String articleTitle = "";
            List<String> highList = highlighting.get(document.get("id").get("article_title"));
            if(highList != null && highList.size() > 0){
                articleTitle = highList.get(0);
            }else{
                articleTitle = (String)document.get("article_title");
            }
            result.setArticle_title(articleTitle);
        }
        return results;
    }
}
```

##### 创建controller

和其他服务提供者一样





















