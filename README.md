# Brazilian E-Commerce Data Warehouse & Analytics

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue.svg)](https://www.postgresql.org/)
[![Pentaho](https://img.shields.io/badge/Pentaho-Data%20Integration-orange.svg)](https://www.hitachivantara.com/en-us/products/dataops-software/data-integration-analytics/pentaho-platform.html)
[![PowerBI](https://img.shields.io/badge/PowerBI-Visualization-yellow.svg)](https://powerbi.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## 📊 Project Overview

This project was create by: Lidor Shachar, Andreas Moen and Lars Andreas Strand.  
It implements a comprehensive Business Intelligence solution for Brazilian e-commerce data (Olist dataset from kaggle.com). It demonstrates end-to-end data engineering, analytics, and visualization capabilities, transforming raw data into actionable business insights.

### Business Context
Olist is a Brazilian marketplace connecting small businesses with customers. This project analyzes their operations to optimize delivery routes, predict customer satisfaction, and provide descriptive analytics for strategic decision-making.

## 🏗️ Architecture

### Data Warehouse Schema
- **Star Schema**: 7 dimensions (Date, Geography, Customer, Product, Seller, Payment Type, Order Status) and 3 fact tables (Sales, Delivery Performance, Customer Reviews)
- **SCD Type 2**: Implemented for Customer dimension to track historical changes
- **Grain**: Sales fact at order item level, Delivery at order level, Reviews at review level

### ETL Pipeline
- **Pentaho Data Integration**: Automated ETL jobs loading data from CSV sources into PostgreSQL
- **Data Quality**: Validation, error handling, and data cleansing steps
- **Incremental Loading**: Designed for periodic updates

### Analytics Layers
1. **Descriptive Analytics**: Statistical summaries, correlation analysis, and trend identification
2. **Predictive Analytics**: Customer satisfaction prediction using Decision Tree Classifier (71% accuracy)
3. **Prescriptive Analytics**: Delivery route optimization using Linear Programming

## 🛠️ Technologies Used

- **Database**: PostgreSQL
- **ETL**: Pentaho Kettle (PDI)
- **Analytics**: Python (pandas, scikit-learn, PuLP, matplotlib, seaborn)
- **Visualization**: PowerBI
- **Version Control**: Git
- **Documentation**: Markdown, ERD diagrams

## 📈 Key Insights

### Descriptive Analytics
- Revenue trends and seasonal patterns
- Customer segmentation and profitability analysis
- Geographic performance variations

### Predictive Analytics
- Delivery performance identified as primary satisfaction driver
- Model achieves 71% accuracy in predicting high/low satisfaction
- Feature importance: actual delivery days, delay days, freight costs

### Prescriptive Analytics
- Optimized warehouse-to-customer assignments
- Potential 15-25% reduction in delivery times
- 10-20% cost savings through route optimization

## 🚀 Installation & Setup

### Prerequisites
- PostgreSQL 13+
- Python 3.8+
- Pentaho Data Integration 9+
- PowerBI Desktop
- Brazilian E-Commerce Public Dataset by Olist from **_Kaggle_**:  
    ```
    https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
    ```

### Database Setup
1. Create PostgreSQL database: `dw`
2. Run schema creation: `Database/schema_creation.sql`
3. Configure connection in `.env` file

### ETL Execution
1. Open Pentaho Spoon
2. Import jobs from `ETL/` folder
3. Modify the CSV's you downloaded from kaggle to be imported from the correct path
4. Connect the transfomation to your data-warehouse
5. Execute `extract_transform_load.kjb` job or each of the ETL's  
    NOTE: If you run the ETL's idependently, run all dimensions prior to fact tables

### Analytics Setup
1. Install Python dependencies:
   ```bash
   pip install pandas numpy matplotlib seaborn scikit-learn pulp sqlalchemy python-dotenv
   ```
2. Configure database connection in `Analytics/.env`
    ```
    # Database Configuration
    DB_URL=postgresql+psycopg2://your_username:your_password@localhost:5432/your_database

    # Optional: Additional configurations
    DB_HOST=localhost
    DB_PORT=5432
    DB_NAME=your_database
    DB_USER=your_username
    DB_PASSWORD=your_password

    ```
3. Run Jupyter notebooks in order:
  - Descriptive
  - Predictive
  - Prescriptive

### PowerBI Dashboard
1. Open `Dashboard/BI_Dashboard.pbix`


## 📁 Repository Structure

```
├── Database/           # SQL schema and analytical queries
├── ETL/               # Pentaho transformations and jobs
├── Analytics/         # Jupyter notebooks and Python scripts
├── Dashboard/         # PowerBI files and CSV exports
├── Documentation/     # ERD, data dictionary, user guides
├── Screenshots/       # Dashboard visualizations
├── LICENSE            # MIT License
└── README.md          # This file
```

<!-- ## 📊 Dashboard Screenshots

*Add screenshots later, ERD or Dashboard, we'll see* -->

## 🎓 Key Learnings

- End-to-end BI solution implementation
- Data warehouse design principles (star schema, SCD)
- ETL best practices and error handling
- Advanced analytics techniques (predictive modeling, optimization)
- Business intelligence visualization
- Professional project documentation and GitHub portfolio management

## 🤝 Contributing

This is a portfolio project. For suggestions or improvements, please open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Olist for providing the dataset
- Professor Peyman Teymoori for guidance and feedback
- Team members for collaboration

---

*Built as part of BID3000 Business Intelligence course - showcasing professional data engineering and analytics skills.*