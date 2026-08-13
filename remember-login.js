(function(){
  const remembered=localStorage.getItem('safari_session');
  if(remembered&&!sessionStorage.getItem('safari_session')){
    sessionStorage.setItem('safari_session',remembered);
    if(!S.token){location.reload();return}
  }
  document.querySelector('#signOut').addEventListener('click',()=>{
    localStorage.removeItem('safari_session');
    sessionStorage.removeItem('safari_session');
  },true);
})();
