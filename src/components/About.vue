<template>
  <div class="about">
    <h3>About</h3>
    <hr>
    <h5>What is this?</h5>
    <p>A real-time stock tracker for the
      <a href="http://www.neopets.com/stockmarket.phtml" target="_blank" rel="noopener noreferrer">Neopets Stock Market</a>, similar to the former Neodaq.com (RIP).
    </p>

    <h5>When does the site update?</h5>
    <p>
      Every 30 minutes at :00 and :30.
    </p>

    <h5>When does the Neopets Stock Market update?</h5>
    <p>
      About every 30 minutes, but it's not exact. It's hard to predict what minute stocks will update at a given hour, so the site may be a couple minutes behind.
    </p>

    <h5>Credits</h5>
    <p>
      All data from 2006 to 2018 originally came from
      <b>Neodaq.com</b>. Pieces of it were recovered from WaybackMachine snapshots by
      <a href="https://www.reddit.com/r/neopets/comments/7rwxwd/neodaqs_data_collected_from_old_neodaqs_website/" target="_blank" rel="noopener noreferrer">/u/HostilePride</a>.
    </p>
    <p>
      Data from Feb to June 2018 was generously contributed by
      <a href="https://www.reddit.com/user/HostilePride" target="_blank" rel="noopener noreferrer">/u/HostilePride</a>.
    </p>
    <p>
      Thanks!
    </p>
  </div>
</template>

<style scoped>
.about {
  padding: 10px 15px 10px;
}

.about h5 {
  margin: 25px 0 10px;
  font-size: 1.15rem;
  font-weight: 600;
}

.about p {
  margin: 0 0 3px;
}
</style>