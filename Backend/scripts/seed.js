require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { MongoClient } = require('mongodb');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/evaluacion';

// Solo funcionando en Desarrollo, en Producción se debe usar un usuario administrador real
const ADMIN = {
  cedula: '1002003000',
  nombre: 'Administrador General',
  email: 'admin@sistema.edu.co',
  password: '$2b$10$0AjH.JmzYmeRYOSoWPhxqevf1rZ1cQyL2RBsExqkRCCGqX.kAEjiy',
  version: 'V6.6.22',
};

const DIMENSIONES = [
  {
    orden: 1,
    nombre: 'Participación infantil',
    descripcion: '¿La planificación facilita la participación del niño?',
    fundamentos: 'Rutas de participación de Shier (2001) y componente «Espacio» de Lundy (2007).',
    reactivos: [
      {
        codigo: '1.1',
        enunciado: 'La planificación contempla momentos concretos en los que el niño explora, decide o actúa según su propio criterio.',
        pista: 'Revisar si el documento permite que el niño pueda, por ejemplo, aportar a la Hoja Exploradora o elegir qué representar.',
      },
      {
        codigo: '1.2',
        enunciado: 'Las actividades permiten que el niño genere contenidos o respuestas propias.',
        pista: 'Verificar que el niño no se limite solo a ejecutar consignas predefinidas por el adulto.',
      },
      {
        codigo: '1.3',
        enunciado: 'Se prevén tiempos, espacios y recursos suficientes para que todos los niños puedan participar.',
        pista: 'Identificar si se contemplan materiales accesibles y una adecuada organización del aula y del hogar.',
      },
      {
        codigo: '1.4',
        enunciado: 'La participación del niño está presente en más de un momento de la secuencia.',
        pista: 'Comprobar si dicha participación ocurre en momentos como el lanzamiento, la indagación o la socialización, y no solo al inicio o al final.',
      },
      {
        codigo: '1.5',
        enunciado: 'La planificación amplía el espacio participativo al entorno familiar.',
        pista: 'Observar si se involucra a la familia como mediadora de la voz del niño.',
      },
    ],
    version: 'V6.6.22',
  },
  {
    orden: 2,
    nombre: 'Voz del niño',
    descripcion: '¿La voz del niño es escuchada?',
    fundamentos: 'Componentes «Voz» y «Audiencia» de Lundy (2007) y artículo 12 de la CDN.',
    reactivos: [
      {
        codigo: '2.1',
        enunciado: 'La planificación incorpora preguntas mediadoras o estrategias explícitas para recoger las opiniones, ideas y emociones del niño.',
        pista: 'Identificar en la redacción la presencia de estas preguntas o estrategias de escucha.',
      },
      {
        codigo: '2.2',
        enunciado: 'Se prevén medios de expresión accesibles para niños que aún no leen ni escriben.',
        pista: 'Buscar si se promueve el uso del dibujo, pictogramas, oralidad o dramatización.',
      },
      {
        codigo: '2.3',
        enunciado: 'Se contempla registrar o documentar lo que el niño expresa, de modo que su voz quede visible.',
        pista: 'Revisar si el documento incluye el uso de la hoja exploradora, un mural o una ficha de observación para este fin.',
      },
      {
        codigo: '2.4',
        enunciado: 'Las expresiones del niño tienen una audiencia real: se prevén instancias en las que alguien las escucha y las considera.',
        pista: 'Analizar si las voces son escuchadas y tomadas en cuenta por el docente, el grupo o la familia.',
      },
      {
        codigo: '2.5',
        enunciado: 'La planificación orienta a validar la expresión del niño sin corregirla ni sustituirla.',
        pista: 'Comprobar que se indique el respeto a la autenticidad de la respuesta del niño.',
      },
    ],
    version: 'V6.6.22',
  },
  {
    orden: 3,
    nombre: 'Relación simétrica',
    descripcion: '¿La planificación promueve una relación simétrica y no adultocéntrica?',
    fundamentos: 'Componente «Influencia» de Lundy (2007), escalera de Hart (1997) y crítica al adultocentrismo.',
    reactivos: [
      {
        codigo: '3.1',
        enunciado: 'La planificación posiciona al docente como mediador del pensamiento y no como única fuente de decisión y conocimiento.',
        pista: 'Observar si el rol del docente se describe desde la mediación en lugar de la imposición.',
      },
      {
        codigo: '3.2',
        enunciado: 'Las decisiones sobre la actividad se comparten con el niño y no las define exclusivamente el adulto.',
        pista: 'Verificar si el niño opina sobre qué se hace, cómo y con qué se realiza la actividad.',
      },
      {
        codigo: '3.3',
        enunciado: 'La voz del niño tiene influencia real: lo que expresa nutre o modifica el desarrollo de la actividad o la construcción colectiva.',
        pista: 'Buscar si las aportaciones del niño se materializan en algo concreto, por ejemplo, en la creación del mural.',
      },
      {
        codigo: '3.4',
        enunciado: 'El lenguaje y las consignas reconocen al niño como sujeto capaz y competente, no como receptor pasivo.',
        pista: 'Analizar la redacción de las consignas para asegurar que se dirigen a un participante activo.',
      },
      {
        codigo: '3.5',
        enunciado: 'La planificación reconoce y respeta la autonomía progresiva del niño, distinguiendo lo que puede hacer por sí mismo y aquello en lo que requiere acompañamiento.',
        pista: 'Identificar si se diferencia claramente el trabajo independiente del niño del apoyo que le brinda el adulto.',
      },
    ],
    version: 'V6.6.22',
  },
];

function generarEvaluaciones() {
  const evaluaciones = [];
  const docentes = [
    { cedula: '1098765432', nombre: 'María López' },
    { cedula: '1087654321', nombre: 'Carlos Ramírez' },
    { cedula: '1076543210', nombre: 'Ana García' },
  ];

  const perfiles = [
    [4, 3, 4, 4, 3, 3, 4, 3, 4, 3, 2, 3, 2, 3, 2],
    [2, 2, 3, 2, 1, 1, 2, 1, 2, 1, 3, 2, 3, 2, 3],
    [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  ];

  const codigosReactivos = [
    '1.1', '1.2', '1.3', '1.4', '1.5',
    '2.1', '2.2', '2.3', '2.4', '2.5',
    '3.1', '3.2', '3.3', '3.4', '3.5',
  ];

  for (let i = 0; i < docentes.length; i++) {
    const respuestas = codigosReactivos.map((codigo, idx) => ({
      reactivo_codigo: codigo,
      valor: perfiles[i][idx],
    }));

    const subtotalD1 = perfiles[i].slice(0, 5).reduce((a, b) => a + b, 0);
    const subtotalD2 = perfiles[i].slice(5, 10).reduce((a, b) => a + b, 0);
    const subtotalD3 = perfiles[i].slice(10, 15).reduce((a, b) => a + b, 0);

    const maxPorDimension = 20;
    const id1 = parseFloat(((subtotalD1 / maxPorDimension) * 100).toFixed(1));
    const id2 = parseFloat(((subtotalD2 / maxPorDimension) * 100).toFixed(1));
    const id3 = parseFloat(((subtotalD3 / maxPorDimension) * 100).toFixed(1));

    const igpp = parseFloat(((id1 + id2 + id3) / 3).toFixed(1));

    const indices = { ID1: id1, ID2: id2, ID3: id3 };
    const dimensionPrioritaria = Object.entries(indices)
      .sort(([, a], [, b]) => a - b)[0][0]
      .replace('ID', 'D');

    evaluaciones.push({
      datos_docente: docentes[i],
      respuestas,
      resultados: {
        subtotales: { D1: subtotalD1, D2: subtotalD2, D3: subtotalD3 },
        indices_dimensionales: indices,
        IGPP: igpp,
        dimension_prioritaria: dimensionPrioritaria,
      },
      version: 'V6.6.22',
    });
  }

  return evaluaciones;
}

async function seed() {
  const client = new MongoClient(MONGODB_URI);

  try {
    await client.connect();
    console.log('Conectado a MongoDB');

    const db = client.db();

    const collections = ['administradores', 'dimensiones', 'evaluaciones'];
    for (const col of collections) {
      const exists = await db.listCollections({ name: col }).hasNext();
      if (exists) {
        await db.collection(col).deleteMany({});
        console.log(`Colección '${col}' limpiada`);
      }
    }

    await db.collection('administradores').insertOne(ADMIN);
    console.log('Admin insertado:', ADMIN.cedula);

    await db.collection('dimensiones').insertMany(DIMENSIONES);
    console.log('Dimensiones insertadas:', DIMENSIONES.length);

    const evaluaciones = generarEvaluaciones();
    await db.collection('evaluaciones').insertMany(evaluaciones);
    console.log('Evaluaciones insertadas:', evaluaciones.length);

    console.log('Seed completado exitosamente');
  } catch (error) {
    console.error('Error durante el seed:', error);
    process.exit(1);
  } finally {
    await client.close();
  }
}

seed();
