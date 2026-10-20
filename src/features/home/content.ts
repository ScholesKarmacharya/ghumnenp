import hero from "../../../public/images/home/hero.webp";
import mustang from "../../../public/images/home/mustang.webp";
import pokhara from "../../../public/images/home/pokhara.webp";
import chitwan from "../../../public/images/home/chitwan.webp";
import rara from "../../../public/images/home/rara.webp";
import bandipur from "../../../public/images/home/bandipur.webp";
import overland from "../../../public/images/home/overland.webp";
import annapurna from "../../../public/images/home/annapurna.webp";
import canoe from "../../../public/images/home/canoe.webp";
import camping from "../../../public/images/home/camping.webp";
import heritage from "../../../public/images/home/heritage.webp";
import helicopter from "../../../public/images/home/helicopter.webp";
import dolpo from "../../../public/images/home/dolpo-guide.webp";
import monsoon from "../../../public/images/home/monsoon-guide.webp";
import teahouse from "../../../public/images/home/teahouse-guide.webp";
import permits from "../../../public/images/home/permits-guide.webp";

export const heroImage = hero;

// Editorial presentation data from the owner's Stitch reference. These are NOT
// database listings, reviewed agencies, quotes, or availability records.
export const destinations = [
  {
    name: "Mustang",
    region: "Ancient Kingdom of Lo",
    description:
      "Wind-carved ochre gorges, walled monastic citadels, and Tibetan Buddhist architecture beyond the Annapurna massif.",
    image: mustang,
    alt: "Ochre cliffs and a hilltop monastery beneath the Himalayas",
    wide: true,
  },
  {
    name: "Pokhara Valley",
    region: "Lakeside Sanctuary",
    description:
      "Quiet shorelines and the Annapurna skyline. Make space for a slower kind of mountain journey.",
    image: pokhara,
    alt: "Boats on a still lake with snowy mountains reflected in the water",
    wide: true,
  },
  {
    name: "Chitwan",
    region: "Subtropical Lowlands",
    description:
      "Sal forests, river landscapes, and the living heritage of the lowlands.",
    image: chitwan,
    alt: "A rhinoceros beside a misty forest river",
    wide: false,
  },
  {
    name: "Rara Lake",
    region: "Untamed West",
    description:
      "Alpine water, pine-covered hills, and wide-open space in Nepal’s west.",
    image: rara,
    alt: "Blue alpine lake surrounded by pine forest",
    wide: false,
  },
  {
    name: "Bandipur Ridge",
    region: "Living Heritage",
    description:
      "Newari trading streets, carved wooden balconies, and Himalayan panoramas.",
    image: bandipur,
    alt: "Traditional brick and timber buildings along a village street",
    wide: false,
  },
] as const;

export type JourneyPreview = {
  id: string;
  title: string;
  place: string;
  region: "mustang" | "annapurna" | "terai" | "west" | "heritage" | "everest";
  days: number;
  category: "trek" | "culture" | "wildlife" | "flight";
  style: string;
  description: string;
  interests: readonly string[];
  image: typeof hero;
  alt: string;
};

export const journeyPreviews: readonly JourneyPreview[] = [
  {
    id: "mustang",
    title: "Upper Mustang Overland 4×4 Expedition",
    place: "Upper Mustang",
    region: "mustang",
    days: 10,
    category: "culture",
    style: "Overland exploration",
    description:
      "An illustrative journey through Kali Gandaki landscapes, heritage villages, and the walled city of Lo Manthang.",
    interests: ["Heritage villages", "Mountain landscapes"],
    image: overland,
    alt: "An expedition vehicle on a winding Himalayan mountain road",
  },
  {
    id: "annapurna",
    title: "Annapurna Sanctuary & Poon Hill Dawn",
    place: "Annapurna Sanctuary",
    region: "annapurna",
    days: 12,
    category: "trek",
    style: "Mountain trekking",
    description:
      "An itinerary concept connecting forest trails, mountain villages, and the glacial landscapes of the Annapurnas.",
    interests: ["Walking trails", "Sunrise viewpoints"],
    image: annapurna,
    alt: "A walker looking across snowy peaks at sunrise",
  },
  {
    id: "chitwan",
    title: "Chitwan Wildlife & River Canoe Journey",
    place: "Chitwan National Park",
    region: "terai",
    days: 4,
    category: "wildlife",
    style: "Nature & culture",
    description:
      "Imagine quiet river mornings, forest exploration, and time to discover the culture of the lowlands.",
    interests: ["River landscapes", "Wildlife"],
    image: canoe,
    alt: "A wooden canoe on a calm river beside dense jungle",
  },
  {
    id: "rara",
    title: "Rara Lake Wilderness Camping Trail",
    place: "Mugu, Karnali",
    region: "west",
    days: 8,
    category: "trek",
    style: "Wilderness walking",
    description:
      "A planning idea for Nepal’s west, with lakeside walks, pine forests, and expansive mountain views.",
    interests: ["Alpine lakes", "Camping"],
    image: camping,
    alt: "Tents beside a blue mountain lake at dusk",
  },
  {
    id: "heritage",
    title: "Sacred Valley & Newari Living Heritage",
    place: "Kathmandu & Bandipur",
    region: "heritage",
    days: 6,
    category: "culture",
    style: "Cultural discovery",
    description:
      "A sample route through carved timber courtyards, historic squares, and the hilltop streets of Bandipur.",
    interests: ["Architecture", "Village stays"],
    image: heritage,
    alt: "Carved wooden windows and warm brickwork in a traditional courtyard",
  },
  {
    id: "everest",
    title: "Everest by Air: A Himalayan Perspective",
    place: "Khumbu Region",
    region: "everest",
    days: 1,
    category: "flight",
    style: "Aerial inspiration",
    description:
      "An aerial itinerary concept for your planning brief. Operators, flights, conditions, and costs are not confirmed.",
    interests: ["Himalayan views", "Aerial journeys"],
    image: helicopter,
    alt: "A helicopter on a mountain landing area below snowy peaks",
  },
];

export const storyPreviews = [
  {
    title: "The Hidden Salt Routes of Upper Dolpo",
    category: "Expedition Longform",
    description:
      "A future field guide to the landscapes, communities, and old trading routes beyond the rain shadow of Dhaulagiri.",
    image: dolpo,
    alt: "A caravan following a rocky Himalayan mountain trail",
  },
  {
    title: "Monsoon Magic: A Slower Side of Bandipur & Pokhara",
    category: "Seasonal Travel",
    description:
      "Emerald terraces, quiet village streets, and dramatic cloud-filled skies.",
    image: monsoon,
    alt: "Green terraced hills and village rooftops in mountain mist",
  },
  {
    title: "A Beginner’s Guide to Teahouse Etiquette",
    category: "Culture & Community",
    description:
      "The shared spaces, everyday rituals, and hospitality of mountain lodges.",
    image: teahouse,
    alt: "A warm wooden teahouse dining room with steaming bowls on a table",
  },
  {
    title: "Planning Ahead: Permits & Trail Preparation",
    category: "Practical Planning",
    description:
      "A future resource for checking current requirements with official sources before you travel.",
    image: permits,
    alt: "Travel documents and a mountain trail checkpoint",
  },
] as const;
