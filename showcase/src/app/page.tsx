import { Analytics } from "@/components/analytics";
import { Architecture } from "@/components/architecture";
import { Assistant } from "@/components/assistant";
import { Automation } from "@/components/automation";
import { Footer } from "@/components/footer";
import { Hero } from "@/components/hero";
import { Lessons } from "@/components/lessons";
import { Metrics } from "@/components/metrics";
import { Nav } from "@/components/nav";
import { Personas } from "@/components/personas";
import { Problem } from "@/components/problem";
import { Release } from "@/components/release";
import { Roadmap } from "@/components/roadmap";
import { SalesCloud } from "@/components/sales";
import { Security } from "@/components/security";
import { ServiceCloud } from "@/components/service";
import { Support } from "@/components/support";

export default function Home() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <Problem />
        <Architecture />
        <Personas />
        <SalesCloud />
        <ServiceCloud />
        <Automation />
        <Security />
        <Analytics />
        <Release />
        <Support />
        <Assistant />
        <Metrics />
        <Lessons />
        <Roadmap />
      </main>
      <Footer />
    </>
  );
}
