const userTransaction = JSON.parse(localStorage.getItem("transactions"));
const User = JSON.parse(localStorage.getItem("User"));

console.log(User);
console.log(userTransaction);

function generateCountDown(timestamp) {
  const now = new Date().getTime();
  const target = timestamp * 1000; // Convert Unix timestamp (seconds) to milliseconds
  const difference = target - now;

  if (difference <= 0) return "0m0s";

  const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((difference % (1000 * 60)) / 1000);

  return `${minutes}m${seconds}s`;
}

const contractTransactionList = document.querySelector(".dataUserTransaction");
const UserProfile = document.querySelector(".contract-user");

// const userTransactionHistory = userTransaction.map((transaction, i) => {
//   return `
//     <div class="col-12 col-md-6 col-lg-4 item explore-item" data-groups='["ongoing","ended"]'>
//     <div class="card project-card">
//       <div class="media">
//         <a href="project-details.html">
//           <img src="assets/img/content/thumb_${i + 1}.png" alt="" class="card-img-top avatar-max-ig"/>
//         </a>

//         <div class="media-body ml-4">
//           <a class="project-details.html">
//             <h4 class="m-0">#tbCoders</h4>
//           </a>
//           <div class="countdown-times">
//             <h6 class="my-2">Transaction NO: ${i + 1}</h6>

//             <div class="countdown d-flex" data-data="2022-06-30"></div>
//           </div>
//       </div>
//     </div>

//     <div class="card-body">
//       <div class="items">
//         <div class="single-item">
//           <span>
//           ${transaction.token / 10 ** 18 ? "Amount" : "ClaimToken"}  
//           </span>
//           <span>${transaction.token / 10 ** 18 || ""}</span>
//         </div>
//         <div class="single-item">
//           <span>${transaction.gas}</span>
//           <span></span>
//         </div>
//         <div class="single-item">
//           <span>Status</span>
//           <span>${transaction.status}</span>
//         </div>
//       </div>
//     </div>

//     <div class="project-footer d-flex align-item-center">
//       <a class="btn btn-bordered-white btn-smaller" href="https://amoy.polygonscan.com/tx/${transaction.transactionHash}">Transaction</a>

//       <div class="social-share ml-auto">
//         <ul class="d-flex list-unstyled">
//           <li>
//             <a href="#">
//               <i class="fab fa-twitter"></i>
//             </a>
//             <a href="#">
//               <i class="fab fa-telegram"></i>
//             </a>
//             <a href="#">
//               <i class="fab fa-globe"></i>
//             </a>
//             <a href="#">
//               <i class="fab fa-discord"></i>
//             </a>
//           </li>
//         </ul>
//       </div>
//     </div>

//     <div class="blockchain-icon">
//       <img src="assets/img/content/ethereum.png" alt="">
//     </div>
//   </div>
    
//     `
// })

// contractTransactionList.innerHTML = userTransactionHistory;

const UserProfileHtml = `
<div class="contract-user-profile">
<img src="assets/img/content/team_1.png" alt="" />
<div class="contract-user-profile-info">
  <p><strong>Address:</strong> ${User.address.slice(0, 25)}</p>

  <span class="contract-space"><strong>Last Reward Calculation Time:</strong>${generateCountDown(User.lastRewardCalculationTime)}</span>
  <span class="contract-space"><strong>Last Stake Time:</strong>${generateCountDown(User.lastStakeTime)}</span>
  <span class="contract-space"><strong>Reward Amount:</strong>${User.rewardAmount / 10 ** 18}</span>
  <span class="contract-space"><strong>Rewards Claimed So Far:</strong>${User.rewardsClaimedSoFar / 10 ** 18}</span>
  <span class="contract-space"><strong>Stake Amount:</strong>${User.stakeAmount / 10 ** 18}</span>
  <p class="contract-paragraph">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Cum labore quos itaque culpa hic voluptatem sint dolorum tempore magni quisquam? Necessitatibus, similique! Dignissimos voluptatibus necessitatibus numquam aspernatur pariatur illo maiores?</p>

</div>
</div>
`;

UserProfile.innerHTML = UserProfileHtml;
