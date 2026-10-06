package com.mycompany.rumahsakit.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBConnection {

    private static final String HOST = System.getProperty("db.host", "localhost");
    private static final String PORT = System.getProperty("db.port", "3306");
    private static final String NAMA_DB = System.getProperty("db.name", "rumah_sakit");
    private static final String USER = System.getProperty("db.user", "root");
    private static final String PASSWORD = System.getProperty("db.password", "");

    private static final String URL = "jdbc:mysql://" + HOST + ":" + PORT + "/" + NAMA_DB
            + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Jakarta&characterEncoding=UTF-8";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver MySQL tidak ditemukan. Pastikan mysql-connector-j ada di classpath.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
