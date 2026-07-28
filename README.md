# 🚀 Project Signalize: L2 Incident Triage & RCA Sandbox

Проект симулирует рабочее окружение инженера технической поддержки L2 (Tier 2 Support / Incident Analyst) в сфере E-commerce / Telecom. 

**Главная цель:** Демонстрация регламентов локализации сбоев, анализа логов, работы с СУБД и составления валидированных баг-репортов для L3-разработки с целью снижения MTTR (Mean Time to Resolution).

---

## 🛠 Активные модули:

### 1. 🔍 [SQL Diagnostics & Anomaly Engine](./SQL_Diagnostics)
Симулятор PostgreSQL с синтетическим потоком данных (200+ транзакций) и вшитыми аномалиями business-логики.
* **Покрытые сценарии:** Money Leak (рассинхрон статусов), SLA Breach (504 Timeout), Promo Abuse (Fraud) и Orphaned Records.
* **Файлы модуля:** `01_init_schema_and_anomalies.sql`, `02_diagnostic_queries.sql`.
* 🔗 **Перейти к интерактивному демо 👉 https://dbfiddle.uk/H8bwi8qh**

---

## 🗺 Roadmap (План развития репозитория)

- [x] **SQL Diagnostics:** Симулятор аномалий и диагностические запросы (PostgreSQL)
- [ ] **Escalation Management:** Шаблоны баг-репортов для L3-эскалации
- [ ] **API Integration Triage:** Коллекция Postman и валидация JSON-ответов / HTTP-статусов
- [ ] **Log Parsing & CLI:** Анализ сырых логов (Nginx/App) с использованием RegEx и bash-утилит
- [ ] **Financial Reconciliation:** Сверка реестров эквайринга с БД (Excel / VLOOKUP / Pivot Tables)

---

## 🏢 Доменная область и контекст
Симулируемая система: **Мультиплатформенный E-commerce сервис с внешними интеграционными контурами** (партнерские сети **Tele2_Zone Gateway**, платежные эквайринги и промо-сервисы).
