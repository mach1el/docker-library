ARG CB_TAG=latest
FROM dbeaver/cloudbeaver:${CB_TAG}

USER root

# For downloading drivers during build
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends curl ca-certificates; \
  rm -rf /var/lib/apt/lists/*

# --- Versions you can bump/pin as needed ---
ARG OJ_VER=23.26.0.0.0         # Oracle JDBC + security libs
ARG MSSQL_VER=12.8.1.jre11     # SQL Server JDBC (optional)
ARG MYSQL_VER=9.0.0            # MySQL JDBC (optional)
ARG PG_VER=42.7.4              # PostgreSQL JDBC (optional)
ARG H2_VER=2.2.224             # H2 JDBC jar (optional fallback)

ENV CB_HOME=/opt/cloudbeaver \
    CB_DRIVERS=/opt/cloudbeaver/drivers \
    ORA_DIR=/opt/cloudbeaver/drivers/oracle \
    EXTRA_DIR=/opt/cloudbeaver/drivers/extra \
    WALLETS_DIR=/opt/cloudbeaver/wallets

# Create target dirs without touching built-in drivers
RUN mkdir -p "$ORA_DIR" "$EXTRA_DIR" "$WALLETS_DIR"

# ---- Oracle thin + Wallet/TCPS libs ----
# ojdbc17 works on modern JREs (17/21). If you prefer, switch to ojdbc11.
RUN set -eux; \
  curl -fsSL -o "$ORA_DIR/ojdbc17-${OJ_VER}.jar" \
    "https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc17/${OJ_VER}/ojdbc17-${OJ_VER}.jar"; \
  curl -fsSL -o "$ORA_DIR/oraclepki-${OJ_VER}.jar" \
    "https://repo1.maven.org/maven2/com/oracle/database/security/oraclepki/${OJ_VER}/oraclepki-${OJ_VER}.jar";
  # curl -fsSL -o "$ORA_DIR/osdt_core-${OJ_VER}.jar" \
  #   "https://repo1.maven.org/maven2/com/oracle/database/security/osdt_core/${OJ_VER}/osdt_core-${OJ_VER}.jar"; \
  # curl -fsSL -o "$ORA_DIR/osdt_cert-${OJ_VER}.jar" \
  #   "https://repo1.maven.org/maven2/com/oracle/database/security/osdt_cert/${OJ_VER}/osdt_cert-${OJ_VER}.jar"

# ---- Optional: preload some common drivers for air-gapped use ----
RUN set -eux; \
  curl -fsSL -o "$EXTRA_DIR/mssql-jdbc-${MSSQL_VER}.jar" \
    "https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_VER}/mssql-jdbc-${MSSQL_VER}.jar"; \
  curl -fsSL -o "$EXTRA_DIR/mysql-connector-j-${MYSQL_VER}.jar" \
    "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_VER}/mysql-connector-j-${MYSQL_VER}.jar"; \
  curl -fsSL -o "$EXTRA_DIR/postgresql-${PG_VER}.jar" \
    "https://repo1.maven.org/maven2/org/postgresql/postgresql/${PG_VER}/postgresql-${PG_VER}.jar"; \
  curl -fsSL -o "$EXTRA_DIR/h2-${H2_VER}.jar" \
    "https://repo1.maven.org/maven2/com/h2database/h2/${H2_VER}/h2-${H2_VER}.jar"

# (Optional) If you want to bake a default server config into the image:
# COPY conf/cloudbeaver.conf /opt/cloudbeaver/conf/cloudbeaver.conf

# Workspace for data sources and user settings (persist via volume)
RUN chown -R root:root "$CB_HOME"

EXPOSE 8978
# Keep the base entrypoint/cmd provided by the official image