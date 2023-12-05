export default {
  async fetch(request, env) {
    const Day0 = 'your1.domain.eu.org'
    const Day1 = 'your2.domain.eu.org'
    const Day2 = 'your3.domain.eu.org'
    const Day3 = 'your4.domain.eu.org'
    const Day4 = 'your5.domain.eu.org'
    const Day5 = 'your6.domain.eu.org'
    const Day6 = 'your7.domain.eu.org'
    let host = ''
    let nd = new Date();
      let day = nd.getDay();
      if (day === 0) {
          host = Day0
      } else if (day === 1) {
          host = Day1
      } else if (day === 2) {
          host = Day2
      } else if (day === 3){
          host = Day3
      } else if (day === 4) {
          host = Day4
      } else if (day === 5) {
          host = Day5
      } else if (day === 6) {
          host = Day6
      } else {
          host = Day1
      }

    let url = new URL(request.url);
    if (url.pathname.startsWith('/')) {
      url.hostname=host;
      let new_request=new Request(url,request);
      return fetch(new_request);
    }
    // Otherwise, serve the static assets.
    return env.ASSETS.fetch(request);
  }
};
