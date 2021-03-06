#술조타그래 iOS

### 1. 프로젝트 개요
 술조타그래는 술을 좋아 하는 어른들을 위한 문화를 돕기 위한 소셜네트워크서비스(SNS)입니다.
술, 안주, 장소에 대한 분류를 설정하고, 사진과 함께 내용을 등록하면 술조타그래를 사용하는 사용자들끼리 공유하여 정보를 찾기 쉽게 제공을 해드립니다.

### 2. 프로젝트 목표(iOS기준)
- 1차목표 (7/29) : SNS를 위한 기초 기반 다지기
    * 기본적인 포스트, 댓글
    * 유저설정
    * 로그인, 회원가입 등
    * 뷰어를 구성하면서 필요한 통신모듈 및 유저정보 공통화 작업
- 2차목표 (미정) :  기초를 기반으로 하여 디테일 부분 구현
     * 포스팅 위치 표기 (사진 GPS메타 데이터 및 위치기반 추가)
     * 보기 싫은 포스팅 차단 기능
     * 포스팅 사진 여러장 설정
    
### 3. 프로젝트 사용된 기술
- **CocoaPods**
    - AFNetworking
     : 네트워킹 프레임워크
    - SDWebImage 
    : 서버이미지를 위한 프레임워크
    - FacebookSDK 
    : 소셜로그인을 위한 SDK
- **그 외**
    - KeychainItemWrapper (앱 내부에 사용자 정보를 저장기 위한 키체인 라이브러리)
    - RFQuiltLayout (콜렉션뷰의 셀의 크기를 조정하여 레이아웃을 변경 할수 있는 라이브러리)


###4. 팀원소개 및 역활(iOS)
- **팀명 : alcoholic**
- 강준 (PL)
    - 통신, 유저 싱글톤패턴을 이용한 공통화 작업
    - 로그인 뷰, 메인뷰(로그인후 보이는 화면) 구성 및 기능 구현
    - 추가개발 및 미비된 부분 수정 보완
    - 연락처
        - 이  메  일  : [wajl1004@gmail.com](wajl1004@gmail.com)
        - 로켓펀치 : [@wajl1004](https://www.rocketpunch.com/@wajl1004)
- 허홍준
    - 포스트, 댓글, 회원가입, 유저 프로필 화면 등 디테일 뷰
    

###5. 협업에 사용된 방법
- 회의방법
    - 스크럼 
    : 주 3회(월, 수,금) (전체) 
    : 1-3일 기준 스프린트 형식으로 진행 (팀별)
- 사용도구
    - Slack : 팀 메신저 및 자료 전송
    - 팀뷰어 : 컴퓨터 화면을 공유해서 보여야 할때 사용   
    - 트렐로 : 팀 전체 상황판  
    - 구글드라이브 : 기록에 필요한 문서들 저장
    - 형상관리 : 깃허브

- 링크
    - 트렐로 : [https://trello.com/b/88z7rMDo](https://trello.com/b/88z7rMDo)
    - 구글문서
        - 회의록 : [https://goo.gl/8KeS9q](https://goo.gl/8KeS9q)
        - 기획안 : [https://goo.gl/vRKK2j](https://goo.gl/vRKK2j)
        

