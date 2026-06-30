require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { MongoClient } = require('mongodb');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/evaluacion';

// Solo funcionando en Desarrollo, en Producción se debe usar un usuario administrador real
const ADMIN = {
  cedula: '1002003000',
  nombre: 'Administrador General',
  password: '$2b$10$0AjH.JmzYmeRYOSoWPhxqevf1rZ1cQyL2RBsExqkRCCGqX.kAEjiy',
  version: 'V6.6.30',
};

const DIMENSIONES = [
  {
    orden: 1,
    nombre: 'Participación infantil',
    descripcion: '¿La planificación facilita la participación del niño?',
    fundamento: 'Rutas de participación de Shier (2001) y componente «Espacio» de Lundy (2007).',
    reactivos: [
      {
        reactivo_codigo: '1.1',
        enunciado: 'La planificación incluye momentos concretos donde el niño puede explorar, decidir o actuar por sí mismo.',
        pista: 'Verifica que el docente plantee momentos para que el niño explore, elija y participe activamente en las actividades',
      },
      {
        reactivo_codigo: '1.2',
        enunciado: 'La planificación permite que el maestro conozca las ideas y opiniones del niño.',
        pista: 'Verifica que el docente proponga actividades que permitan a los niños expresar sus ideas, intereses, opiniones y experiencias durante el proceso de aprendizaje.',
      },
      {
        reactivo_codigo: '1.3',
        enunciado: 'La planificación dispone de tiempos, espacios y materiales para la participación de todos los niños.',
        pista: '¿De qué manera detalla el docente en el documento los recursos específicos (como las hojas bicolores, lápices, pictogramas) y la distribución del tiempo requerido tanto en casa como en el aula para el desarrollo de la actividad?',
      },
      {
        reactivo_codigo: '1.4',
        enunciado: 'La planificación permite que el niño participe en las actividades.',
        pista: '¿Cómo verifica el docente en el documento que el niño se mantenga activo, indagando en casa, socializando en el Mural Colectivo y armando rompecabezas a lo largo de las distintas sesiones?',
      },
      {
        reactivo_codigo: '1.5',
        enunciado: 'La planificación facilitó la participación de la familia.',
        pista: '¿De qué manera asegura el docente en el documento que se incluya una guía o mensaje claro para que los padres acompañen en casa, escuchen y anoten estrictamente lo que el niño les dicta sin cambiar sus respuestas?',
      },
    ],
    version: 'V6.6.22',
  },
  {
    orden: 2,
    nombre: 'Voz del niño',
    descripcion: '¿La voz del niño es escuchada?',
    fundamento: 'Componentes «Voz» y «Audiencia» de Lundy (2007) y artículo 12 de la CDN.',
    reactivos: [
      {
        reactivo_codigo: '2.1',
        enunciado: 'La planificación incorpora preguntas mediadoras claras para conocer las opiniones, ideas y emociones del niño.',
        pista: '¿De qué manera incorpora el docente en el documento listados de preguntas específicas como "¿Qué cosas puedes hacer tú solito?" o "¿Cómo te sientes cuando lo logras?" para guiar la actividad?',
      },
      {
        reactivo_codigo: '2.2',
        enunciado: 'La planificación permite que el niño se exprese de diferentes maneras.',
        pista: '¿El plan menciona que los niños pueden expresarse pegando fotos de revistas, haciendo dibujos o usando pictogramas (fichas visuales) si aún no saben escribir?',
      },
      {
        reactivo_codigo: '2.3',
        enunciado: 'La planificación permite identificar lo que el niño expresa.',
        pista: '¿Cómo establece el docente en el plan que los niños puedan expresarse pegando fotos de revistas, haciendo dibujos o usando pictogramas (fichas visuales) si aún no saben escribir?',
      },
      {
        reactivo_codigo: '2.4',
        enunciado: 'La planificación permite escuchar lo que el niño opina.',
        pista: '¿De qué manera contempla el docente en la actividad planificada reunir las hojas exploradoras de todos para construir un "Mural Colectivo" visible en la clase?',
      },
      {
        reactivo_codigo: '2.5',
        enunciado: 'La planificación permite que el niño sea escuchado sin cambiar su idea original.',
        pista: '¿De qué manera describe el docente en el documento el momento de socialización donde cada niño comparte con sus compañeros lo que descubrió que puede hacer solo o acompañado?',
      },
    ],
    version: 'V6.6.22',
  },
  {
    orden: 3,
    nombre: 'Relación simétrica',
    descripcion: '¿La planificación promueve una relación simétrica y no adultocéntrica?',
    fundamento: 'Componente «Influencia» de Lundy (2007), escalera de Hart (1997) y crítica al adultocentrismo.',
    reactivos: [
      {
        reactivo_codigo: '3.1',
        enunciado: 'La planificación permite que el maestro acompañe al niño.',
        pista: '¿De qué manera evidencia el docente en los pasos de la actividad la formulación de preguntas mediadoras para hacer pensar a los niños (por ejemplo, en los rompecabezas o secuencias) en lugar de simplemente darles la respuesta hecha?',
      },
      {
        reactivo_codigo: '3.2',
        enunciado: 'La planificación permite que el niño tome desiciones.',
        pista: '¿De qué manera evidencia el docente en el diseño de la actividad que se permite a los niños tomar decisiones autónomas, por ejemplo, al elegir por qué pieza empezar a armar su rompecabezas o cómo organizar su serie temporal?',
      },
      {
        reactivo_codigo: '3.3',
        enunciado: 'La planificación considera las ideas de los niños para enriquecer o modificar el desarrollo de las actividades.',
        pista: '¿De qué manera evidencia el docente en el plan que, al construir la "¿Conclusión Colectiva” del grupo, se abre la posibilidad de anotar ideas nuevas surgidas del diálogo con los niños que no estaban inicialmente en los pictogramas?',
      },
      {
        reactivo_codigo: '3.4',
        enunciado: 'La planificación reconoce al niño como un sujeto con autonomía niño.',
        pista: '¿De qué manera evidencia el docente en la redacción del documento técnico que se concibe al niño como un sujeto activo que construye y descubre (utilizando términos como "clasificar", "seriar" o "caracterizar") en lugar de un agente pasivo que solo memoriza?',
      },
      {
        reactivo_codigo: '3.5',
        enunciado: 'La planificación respeta la autonomía progresiva del niño.',
        pista: '¿De qué manera asegura el docente que el eje central de la actividad (identidad y autonomía) guíe al niño a reconocer y verbalizar sus propios límites frente a situaciones de riesgo?',
      },
    ],
    version: 'V6.6.22',
  },
];

function generarEvaluaciones() {
  const evaluaciones = [];
  const cedula_docente = ['1098765432', '1087654321', '1076543210'];

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

  for (let i = 0; i < cedula_docente.length; i++) {
    const respuestas = codigosReactivos.map((reactivo_codigo, idx) => ({
      reactivo_codigo: reactivo_codigo,
      valor: perfiles[i][idx],
    }));

    const comentarios = {
      compromiso_personal: `Compromiso del docente ${cedula_docente[i]}`,
      opiniones_programa: `Opiniones del docente ${cedula_docente[i]}`,
    };

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
      cedula_docente: cedula_docente[i],
      respuestas,
      comentarios,
      resultados: {
        subtotales: { D1: subtotalD1, D2: subtotalD2, D3: subtotalD3 },
        indices_dimensionales: indices,
        IGPP: igpp,
        dimension_prioritaria: dimensionPrioritaria,
      },
      version: 'V6.6.30',
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
