Logstash
======
#### Giới thiệu

- Log là dữ liệu sinh ra khi hệ thống hoạt động, phân tích log và sự kiện (event) của hệ thống là một việc quan trọng với systemaddmin. 
ngoài việc giúp tìm lỗi khi phát sinh sự cố, việc đọc và theo dõi giúp người quản trị kịp thời phát hiện lỗi cũng như hướng giải quyết.
- Tuy nhiên việc đọc những tập tin này rất khó khăn bởi số lượng và nội dung của chúng quá nhiều. Một giải pháp giúp cúng ta phân tích log là bộ 3 Elasticsearch,
Logstash, Kibana (ELK). Đây là sự kết hợp tuyệt vời của Elasticsearch – công cụ tìm kiếm và phân tích thời gian thực – Logstash – công cụ thu thập, chuyển đổi và 
xử lý log cùng các sự kiện theo mốc thời gian trong toàn hệ thống – và Kibana – công cụ cho phép người dùng thao tác với dữ liệu của Elasticsearch một cách trực quan, lưu trữ và chia sẻ dữ liệu phân tích.