# Brazilian E-Commerce Data Warehouse & Analytics

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue.svg)](https://www.postgresql.org/)
[![Pentaho](https://img.shields.io/badge/Pentaho-Data%20Integration-orange.svg)](https://www.hitachivantara.com/en-us/products/dataops-software/data-integration-analytics/pentaho-platform.html)
[![PowerBI](https://img.shields.io/badge/PowerBI-Visualization-yellow.svg)](https://powerbi.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## 📊 Project Overview

This project was created by: [Lidor Shachar](https://github.com/lidizz), [Andreas Moen](https://github.com/Moen01), and [Lars Andreas Strand](https://github.com/Lars263506).  
It implements a comprehensive Business Intelligence solution for Brazilian e-commerce data ([Olist dataset from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)). It demonstrates end-to-end data engineering, analytics, and visualization capabilities, transforming raw data into actionable business insights.

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

- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **ETL**: [Pentaho Kettle (PDI)](https://www.hitachivantara.com/en-us/products/dataops-software/data-integration-analytics/pentaho-platform.html)
- **Analytics**: [Python](https://www.python.org/) (pandas, scikit-learn, PuLP, matplotlib, seaborn)
- **Visualization**: [PowerBI](https://powerbi.microsoft.com/)
- **Version Control**: [Git](https://git-scm.com/)
- **Documentation**: [Markdown](https://www.markdownguide.org/), [ERD diagrams](https://www.draw.io/)

### Resources & Links
- **Dataset**: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)
- **Contributors**: [Lidor Shachar](https://github.com/lidizz), [Andreas Moen](https://github.com/Moen01), [Lars Andreas Strand](https://github.com/Lars263506)
- **Professor**: [Peyman Teymoori](https://www.linkedin.com/in/peyman-teymoori-16a68424/)

## 📈 Key Insights

Based on the analysis of the Olist dataset, here are key answers to business questions derived from descriptive, predictive, and prescriptive analytics:

### Descriptive Analytics
- **Revenue Trends and Seasonal Patterns**: Total revenue peaked in November 2017 ($1.18M), with Q4 showing the highest seasonal performance. Average order value ranges from $130-170, with consistent monthly growth patterns.
- **Customer Segmentation and Profitability**: Analysis shows varying order volumes across months, with peak periods in Q4 due to holiday shopping. Geographic analysis reveals regional differences in order volumes and delivery performance.
- **Geographic Performance Variations**: Delivery times vary significantly by region, with cross-region shipments taking longer. Regional analysis shows satisfaction rates ranging from 64.7% in North-Northeast combinations to 86% in Center-West-North combinations.

### Predictive Analytics
- **Delivery Performance as Satisfaction Driver**: Delivery delays are the primary driver of customer satisfaction, with delay days accounting for 59.7% of model importance. Item count (24.3%) and actual delivery days (11.5%) are also significant factors.
- **Model Performance**: Decision Tree model achieves 71.2% accuracy on test data, with 85.7% precision and 75.6% recall. Cross-validation shows stable performance with 72.1% ± 0.93% accuracy.
- **Feature Importance Breakdown**: Delivery delay days (59.7%), item count (24.3%), actual delivery days (11.5%), estimated delivery days (1.4%), shipping distance (0.8%), freight value (0.6%), and other factors.

### Prescriptive Analytics
- **Delivery Route Optimization**: Linear programming optimization suggests reassigning shipments to reduce cross-region transport, achieving 7.3% cost savings and 20% reduction in average delivery times (from 12.4 to 9.9 days).
- **Warehouse-to-Customer Assignments**: Optimization focuses on regional efficiency, with same-region shipments comprising 86.7% of total volume. This reduces operational complexity and improves delivery reliability.
- **Scalability Insights**: For peak seasons, the model recommends prioritizing same-region logistics, potentially handling 20% more volume with improved satisfaction rates (from 75.9% to 83.5%).

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
    - Download as a zip and extract the CSV's for later use

### Database Setup
1. Create PostgreSQL database: `dw`
2. Run schema creation: `Database/schema_creation.sql`
3. Configure connection in `.env` file (see Analytics Setup step 2)

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
2. Create .env file and configure database connection in `Analytics/.env`
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
├── Database/          # SQL schema and analytical queries
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

- [Professor Peyman Teymoori](https://www.linkedin.com/in/peyman-teymoori-16a68424/) for guidance and feedback
- Team members for collaboration
- [Olist](https://olist.com/) for providing the dataset through [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)


---

*Built as part of a Business Intelligence University course - showcasing professional data engineering and analytics skills.*