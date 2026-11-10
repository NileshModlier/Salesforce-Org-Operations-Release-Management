import type { Metadata } from "next";
import { JetBrains_Mono, Outfit } from "next/font/google";
import "./globals.css";

const outfit = Outfit({
  variable: "--font-outfit",
  subsets: ["latin"],
});

const mono = JetBrains_Mono({
  variable: "--font-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Salesforce Org Operations & Release Management",
  description:
    "Portfolio case study in Salesforce administration, CRM operations, release governance, and an advisory how-to assistant. Developer Edition only.",
  authors: [{ name: "Nilesh P Raghavan" }],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${outfit.variable} ${mono.variable} antialiased`}>
        {children}
      </body>
    </html>
  );
}
