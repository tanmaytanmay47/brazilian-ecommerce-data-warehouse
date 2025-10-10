# Contributing to Brazilian E-Commerce Data Warehouse

Thank you for your interest in contributing to this project! This is a portfolio showcase of a Business Intelligence solution, but contributions for improvements, bug fixes, or enhancements are welcome.

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 13+
- Python 3.8+ with pip
- Pentaho Data Integration 9+
- PowerBI Desktop (for dashboard modifications)
- Git

### Setup
1. Fork and clone the repository:
   ```bash
   git clone https://github.com/your-username/brazilian-ecommerce-data-warehouse.git
   cd brazilian-ecommerce-data-warehouse
   ```

2. Set up Python environment:
   ```bash
   pip install pandas numpy matplotlib seaborn scikit-learn pulp sqlalchemy python-dotenv
   ```

3. Configure database:
   - Create PostgreSQL database named `dw`
   - Run `Database/schema_creation.sql`
   - Update `Analytics/.env` with your database credentials

4. Install Pentaho and import ETL jobs from `ETL/` folder

## 🛠️ Development Guidelines

### Code Style
- **Python**: Follow PEP 8 standards. Use black for formatting.
- **SQL**: Use consistent indentation and comments for complex queries.
- **Documentation**: Update README.md and inline comments for any changes.

### Testing
- Run notebooks in order (descriptive → predictive → prescriptive)
- Verify ETL jobs execute without errors
- Test PowerBI dashboard data refresh

### Commit Messages
Use clear, descriptive commit messages:
```
feat: add new analytics metric
fix: resolve ETL loading error
docs: update installation instructions
```

## 🤝 How to Contribute

1. **Report Issues**: Use GitHub Issues for bugs, feature requests, or questions.
2. **Fork and Branch**: Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make Changes**: Implement your changes with tests/documentation.
4. **Submit PR**: Push to your fork and create a Pull Request with:
   - Clear description of changes
   - Screenshots for UI/dashboard changes
   - Reference to any related issues

### Types of Contributions
- Bug fixes
- Feature enhancements
- Documentation improvements
- Performance optimizations
- Code refactoring

## 📋 Pull Request Process

1. Ensure all tests pass
2. Update documentation as needed
3. Add screenshots for dashboard changes
4. Request review from maintainers
5. Address feedback and merge

## 📞 Contact

For questions or suggestions:
- Open an issue on GitHub
- Email: [your-email@example.com]

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

*This project demonstrates professional BI development skills. Contributions help maintain and improve the showcase.*