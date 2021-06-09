properties配置

```
#Hibernate Configuration
hibernate.naming.strategy=org.hibernate.cfg.DefaultComponentSafeNamingStrategy
hibernate.dialect=org.hibernate.dialect.MySQLDialect
hibernate.hbm2ddl.auto=none
hibernate.connection.autocommit=false
hibernate.ejb.naming_strategy=org.hibernate.cfg.ImprovedNamingStrategy
hibernate.show_sql=false
hibernate.format_sql=false
```

java配置


```
package com.tinckay.common.config;


import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.persistence.EntityManagerFactory;
import javax.sql.DataSource;
import java.util.Properties;


/**
 * @author SAM
 */
@Configuration
@EnableJpaRepositories(basePackages = {
        "com.tinckay.jpa"
})
@EnableTransactionManagement
public class JpaConfig {

    @Bean(destroyMethod = "close")
    DataSource dataSource(Environment env) {
        HikariConfig dataSourceConfig = new HikariConfig();
        dataSourceConfig.setDriverClassName(env.getRequiredProperty("db.driver"));
        dataSourceConfig.setJdbcUrl(env.getRequiredProperty("db.url"));
        dataSourceConfig.setUsername(env.getRequiredProperty("db.username"));
        dataSourceConfig.setPassword(env.getRequiredProperty("db.password"));
        dataSourceConfig.setMaximumPoolSize(10);
        return new HikariDataSource(dataSourceConfig);
    }

    @Bean
    LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource dataSource,
                                                                Environment env) {
        LocalContainerEntityManagerFactoryBean entityManagerFactoryBean = new LocalContainerEntityManagerFactoryBean();
        entityManagerFactoryBean.setDataSource(dataSource);
        entityManagerFactoryBean.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
        entityManagerFactoryBean.setPackagesToScan("com.tinckay.entity");
        Properties jpaProperties = new Properties();

        //Configures the used database dialect. This allows Hibernate to create SQL
        //that is optimized for the used database.
        jpaProperties.put("hibernate.dialect", env.getRequiredProperty("hibernate.dialect"));

        //Specifies the action that is invoked to the database when the Hibernate
        //SessionFactory is created or closed.
        jpaProperties.put("hibernate.hbm2ddl.auto",
                env.getRequiredProperty("hibernate.hbm2ddl.auto")
        );

        //Configures the naming strategy that is used when Hibernate creates
        //new database objects and schema elements
        jpaProperties.put("hibernate.ejb.naming_strategy",
                env.getRequiredProperty("hibernate.ejb.naming_strategy")
        );

        //If the value of this property is true, Hibernate writes all SQL
        //statements to the console.
        jpaProperties.put("hibernate.show_sql",
                env.getRequiredProperty("hibernate.show_sql")
        );

        //If the value of this property is true, Hibernate will format the SQL
        //that is written to the console.
        jpaProperties.put("hibernate.format_sql",
                env.getRequiredProperty("hibernate.format_sql")
        );

        entityManagerFactoryBean.setJpaProperties(jpaProperties);
        return entityManagerFactoryBean;
    }

    @Bean
    JpaTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory);
        return transactionManager;
    }
}

```
xml配置


```
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE hibernate-configuration PUBLIC
    "-//Hibernate/Hibernate Configuration DTD//EN"
    "http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">
<hibernate-configuration>
  <session-factory>
    <property name="connection.url">jdbc:mysql://218.16.128.142:13666/tinckay_air</property>
    <property name="connection.driver_class">com.mysql.jdbc.Driver</property>
      <mapping class="com.tinckay.entity.AirGridman"/>
      <mapping class="com.tinckay.entity.AirGridmanStation"/>
      <mapping class="com.tinckay.entity.AirGridManPollution"/>
      <mapping class="com.tinckay.entity.AirWarnEvent"/>
      <mapping class="com.tinckay.entity.AirWarnRule"/>
      <mapping class="com.tinckay.entity.AirWarnTask"/>
      <mapping class="com.tinckay.entity.AirWarnTaskRecord"/>
      <!-- <property name="connection.username"/> -->
    <!-- <property name="connection.password"/> -->

    <!-- DB schema will be updated if needed -->
    <!-- <property name="hbm2ddl.auto">update</property> -->
  </session-factory>
</hibernate-configuration>
```
数据源配置


```
db.driver=com.mysql.jdbc.Driver
db.username=root
db.password=Tinckay1016xwm
db.url=jdbc:mysql://218.16.128.142:13666/tinckay_air?tinyInt1isBit=true&autoReconnect=true&useSSL=true&characterEncoding=utf-8
```













