<template>
  <div class="about">
    <h1 class="title">About</h1>
    <div class="section">
      <h2 class="section-heading">What is this?</h2>
      <p>
        A real-time stock tracker for the
        <a
          href="http://www.neopets.com/stockmarket.phtml"
        >Neopets Stock Market</a>, similar to the former NeoDaq.com (RIP).
      </p>
    </div>

    <div class="section">
      <h2 class="section-heading">When does the site update?</h2>
      <p>Every half hour, usually within a minute of Neopets Stock Market updates.</p>
    </div>

    <div class="section">
      <h2 class="section-heading">Credits</h2>
      <p>
        All data from 2006 to 2018 originally came from
        NeoDaq.com. Pieces of it were recovered from WaybackMachine snapshots by
        <a
          href="https://www.reddit.com/r/neopets/comments/7rwxwd/neodaqs_data_collected_from_old_neodaqs_website/"
        >/u/HostilePride</a>.
      </p>
      <p>
        Data from Feb to June 2018 was generously contributed by
        <a
          href="https://www.reddit.com/user/HostilePride"
        >/u/HostilePride</a>.
      </p>
      <p>Thanks!</p>
    </div>
  </div>
</template>

<style scoped>
.about {
  padding: 20px 25px 20px;
  max-width: 50em;
}

.title {
  margin-bottom: 1.5rem;
  font-size: 1.25rem;
  color: #555;
}

.section:not(:first-of-type) {
  margin-top: 2rem;
}

.section-heading {
  margin-bottom: 0.5rem;
  font-size: 1.1rem;
  font-weight: 600;
}

.section p {
  margin-bottom: 0.5rem;
  line-height: 1.7rem;
}
</style>