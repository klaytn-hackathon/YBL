pragma solidity ^0.4.24;
import "./Ownable.sol";
import "./POG_Token.sol";


contract POG is Ownable, POG_Token {
    mapping(address => questioner) public questioners; // 질문자의 정보
    mapping(address => voter) public voters; // 투표자의 정보
 

    // 질문자의 정보를 담은 struct
    struct questioner {
        address qAddress; // 질문자의 주소
        uint questionID; // 질문의 ID
        uint createAt; // 질문 생성 시간
    }
    // 투표자의 정보를 담은 struct
    struct voter {
        address vAddress; // 투표자의 주소
        bool voted; // 만약 true이면 그 사람은 이미 투표한 상태
        uint8 voteOn; // 투표한 제안의 인덱스
    }
    // 선택지에 대한 정보를 담은 struct
   // struct choice {
    //    uint choiceID; // 선택지 아이디
      //  uint voteCount; // 누적된 투표 수
//    }
    uint[5] public choice;

    address public YBL; // 스마트 컨트랙트의 주인
    uint8 public choiceSize; // 선택지 수
    uint8 public highestChoice; // 가장 많은 표를 받은 선택지
    uint public questionID;
    uint public endTime;
    
    uint public voteCountSum;
   
    bool public running;
    
    address[] public voterArr;

    event voteEnded(uint8 highestChoice); // 투표 끝나면 이벤트 발생

    //modifier onlyBefore(uint _timer) { require(now < _timer); _; } // 투표 끝나기 전에만
    //modifier onlyAfter(uint _timer) { require(now > _timer); _; } // 투표 끝난 후에만

    // choice struct의 배열
    //choice[] public choices;

    // POG contract의 constructor
    constructor() public {
        running = false;
        choiceSize = 5; // 선택지는 5개
        questionID = 0;
        voteCountSum = 0;
        YBL = msg.sender; 
    }



    // 질문자가 질문을 생성
    function makeQuestion() public {
        require(!running && POG_Token.balanceOf[msg.sender] >= 5);
        endTime = now + (60);

        // 잔고 확인 후 질문을 하면 5POGT가 빠져나감
       
        POG_Token.balanceOf[msg.sender] -= 5; 
        
        // 선택지 저장
       // for (uint i = 0; i < choiceSize; i++) {
        //    choices[questionID][i] = i;
        //    choices[i].voteCount = 0;        
        //}
        
        // 질문자 정보 저장
        questioners[msg.sender] = questioner(msg.sender, questionID, now);
        questionID += 1;

        running = true;
    }
    function getRunning() public returns(bool b){
        if (now >= endTime) { running = false; return running;}
        if (now < endTime) { return running;}
    }

    // 투표하는 함수
    // question id와 어디에 투표했는가(0~4)를 인자로 받아온다
    function vote(uint _questionID, uint8 _voteOn) public {
        require(now < endTime && POG_Token.balanceOf[msg.sender] >= 1 && !voters[msg.sender].voted && running);

        // 잔고 확인 후 답변을 하면 1POGT가 빠져나감
        POG_Token.balanceOf[msg.sender] -= 1;
        
        // 투표자 정보 저장
        voters[msg.sender] = voter(msg.sender, true, _voteOn);
        
        // 투표 수 count
        choice[_voteOn] += 1;
        
        voteCountSum += 1;
        
        voterArr.push(msg.sender);
    }

    function getResult(uint _questionID) returns(uint choiceID) {
        require(now >= endTime);
        uint highestChoiceCount = 0 ;
        for (uint i = 0; i < choiceSize; i++) {
            if (choice[i] >= highestChoiceCount){
                highestChoice = uint8(i);
                highestChoiceCount = choice[i];
            }
        }
        for (uint8 j = 0; j < voteCountSum; j++) {
            if (voters[j].voteOn == uint(highestChoice)){
                POG_Token.balanceOf[voterArr[j]] += (voteCountSum)/highestChoiceCount;
            }
        }
        voters[msg.sender].voted = false;
    }
}