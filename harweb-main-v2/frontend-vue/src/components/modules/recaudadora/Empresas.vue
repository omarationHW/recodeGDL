<template>
  <div>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'EmpresasModule',
};
</script>

<!--
A continuación, se incluyen los componentes de página independientes.
Cada uno debe estar en su propio archivo y ruta, pero aquí se muestran juntos para referencia.
-->

<!-- EmpresasAsignarCuentas.vue -->
<template>
  <div class="empresas-asignar-cuentas">
    <h2>Asignar Cuentas a Empresas</h2>
    <form @submit.prevent="handleFileUpload">
      <div>
        <label>Fecha Trabajo:</label>
        <input type="date" v-model="fechaTrabajo" required />
      </div>
      <div>
        <label>Empresa (Ejecutor):</label>
        <select v-model="selectedEjecutor" required>
          <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">
            {{ e.ejecutor }}
          </option>
        </select>
      </div>
      <div>
        <label>Aplicación:</label>
        <select v-model="selectedApp" required>
          <option value="predial">Predial</option>
          <option value="licencias">Licencias</option>
          <option value="multas">Multas</option>
          <option value="anuncios">Anuncios</option>
        </select>
      </div>
      <div>
        <label>Archivo de cuentas:</label>
        <input type="file" @change="onFileChange" accept=".txt,.csv" required />
      </div>
      <button type="submit">Procesar Archivo</button>
    </form>
    <div v-if="gridData.length">
      <h3>Resultados</h3>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>CveCuenta</th>
            <th>Cuenta</th>
            <th>Estado</th>
            <th>Ejecutor</th>
            <th>Fecha Trabajo</th>
            <th>Texto</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in gridData" :key="idx">
            <td>{{ idx + 1 }}</td>
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.fecha_trabajo }}</td>
            <td>{{ row.texto }}</td>
          </tr>
        </tbody>
      </table>
      <div>
        <p>Seleccionados: {{ gridData.length }}</p>
        <p>Aplicados: {{ stats.aplicados }}</p>
        <p>Duplicados: {{ stats.duplicados }}</p>
        <p>Diferente: {{ stats.diferente }}</p>
      </div>
      <button @click="asignarCuentas">Asignar Cuentas</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EmpresasAsignarCuentas',
  data() {
    return {
      fechaTrabajo: '',
      selectedEjecutor: '',
      selectedApp: '',
      ejecutores: [],
      file: null,
      gridData: [],
      stats: {
        aplicados: 0,
        duplicados: 0,
        diferente: 0
      }
    };
  },
  created() {
    this.loadEjecutores();
  },
  methods: {
    async loadEjecutores() {
      const { data } = await axios.post('/api/execute', {
        eRequest: { action: 'get_ejecutores' }
      });
      this.ejecutores = data.eResponse.data;
    },
    onFileChange(e) {
      this.file = e.target.files[0];
    },
    async handleFileUpload() {
      if (!this.file) return;
      const reader = new FileReader();
      reader.onload = async (e) => {
        const lines = e.target.result.split('\n');
        let aplicados = 0, duplicados = 0, diferente = 0;
        const rows = [];
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line) continue;
          const parts = line.split('|');
          const cvecuenta = parts[0];
          const cuenta = parts[1] || '';
          // Check cuenta
          const { data: check } = await axios.post('/api/execute', {
            eRequest: {
              action: 'check_cuenta',
              cvecuenta,
              cveejecutor: this.selectedEjecutor,
              fecha_trabajo: this.fechaTrabajo
            }
          });
          let estado = '';
          if (check.eResponse.data && check.eResponse.data.cuentas == 1) {
            estado = 'Aplicado';
            aplicados++;
          } else if (check.eResponse.data && check.eResponse.data.cuentas == 2) {
            estado = 'Duplicado';
            duplicados++;
          }
          // Check empresa diferente
          const { data: diff } = await axios.post('/api/execute', {
            eRequest: {
              action: 'check_empresa_diferente',
              cvecuenta,
              cveejecutor: this.selectedEjecutor
            }
          });
          if (diff.eResponse.data && diff.eResponse.data.existe > 0) {
            estado = 'Ejecutor Diferente';
            diferente++;
          }
          rows.push({
            cvecuenta,
            cuenta,
            estado,
            ejecutor: this.selectedEjecutor,
            fecha_trabajo: this.fechaTrabajo,
            texto: line
          });
        }
        this.gridData = rows;
        this.stats = { aplicados, duplicados, diferente };
      };
      reader.readAsText(this.file);
    },
    async asignarCuentas() {
      let aplicados = 0;
      for (const row of this.gridData) {
        if (!row.estado) {
          const { data } = await axios.post('/api/execute', {
            eRequest: {
              action: 'insert_ctaempexterna',
              cvecuenta: row.cvecuenta,
              cveejecutor: row.ejecutor,
              fecha_trabajo: row.fecha_trabajo
            }
          });
          if (data.eResponse.success) {
            row.estado = 'Aplicado';
            aplicados++;
          }
        }
      }
      this.stats.aplicados += aplicados;
      alert('Cuentas asignadas correctamente.');
    }
  }
};
</script>

<!-- EmpresasAsignarFolios.vue -->
<template>
  <div class="empresas-asignar-folios">
    <h2>Asignar y Practicar Folios</h2>
    <form @submit.prevent="buscarFolios">
      <div>
        <label>Aplicación:</label>
        <select v-model="selectedApp" required>
          <option value="predial">Predial</option>
          <option value="licencias">Licencias</option>
          <option value="multas">Multas</option>
          <option value="anuncios">Anuncios</option>
        </select>
      </div>
      <div>
        <label>Fecha Asignación:</label>
        <input type="date" v-model="fechaAsignacion" required />
      </div>
      <div>
        <label>Empresa (Ejecutor):</label>
        <select v-model="selectedEjecutor" required>
          <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">
            {{ e.ejecutor }}
          </option>
        </select>
      </div>
      <div>
        <label>Recaudadora:</label>
        <input type="number" v-model="rec" min="1" max="5" required />
      </div>
      <div>
        <label>Año notificación:</label>
        <input type="number" v-model="axo" min="2022" max="2099" required />
      </div>
      <div>
        <label>Rango Folios Inicial:</label>
        <input type="number" v-model="fdsd" required />
      </div>
      <div>
        <label>Rango Folios Final:</label>
        <input type="number" v-model="fhst" required />
      </div>
      <button type="submit">Buscar Folios</button>
    </form>
    <div v-if="folios.length">
      <h3>Folios Encontrados</h3>
      <table>
        <thead>
          <tr>
            <th>Año</th><th>Rec</th><th>Folio</th><th>Cuenta</th><th>Emisión</th><th>Practicado</th><th>Entrega</th><th>Ejecutor</th><th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in folios" :key="f.folio">
            <td>{{ f.axo }}</td>
            <td>{{ f.rec }}</td>
            <td>{{ f.folio }}</td>
            <td>{{ f.cuenta }}</td>
            <td>{{ f.emision }}</td>
            <td>{{ f.practicado }}</td>
            <td>{{ f.entraga }}</td>
            <td>{{ f.ejecutor }}</td>
            <td>{{ f.total }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="asignarPracticarFolios">Asignar y Practicar</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EmpresasAsignarFolios',
  data() {
    return {
      selectedApp: 'predial',
      fechaAsignacion: '',
      selectedEjecutor: '',
      ejecutores: [],
      rec: 1,
      axo: 2022,
      fdsd: '',
      fhst: '',
      folios: []
    };
  },
  created() {
    this.loadEjecutores();
  },
  methods: {
    async loadEjecutores() {
      const { data } = await axios.post('/api/execute', {
        eRequest: { action: 'get_ejecutores' }
      });
      this.ejecutores = data.eResponse.data;
    },
    async buscarFolios() {
      const modMap = { predial: 5, licencias: 9, multas: 3, anuncios: 10 };
      const { data } = await axios.post('/api/execute', {
        eRequest: {
          action: 'get_empresas_folios',
          rec: this.rec,
          axo: this.axo,
          fdsd: this.fdsd,
          fhst: this.fhst,
          fecha: this.fechaAsignacion,
          ejecutor: this.selectedEjecutor,
          mod: modMap[this.selectedApp],
          opc: 'C'
        }
      });
      this.folios = data.eResponse.data;
    },
    async asignarPracticarFolios() {
      const modMap = { predial: 5, licencias: 9, multas: 3, anuncios: 10 };
      await axios.post('/api/execute', {
        eRequest: {
          action: 'get_empresas_folios',
          rec: this.rec,
          axo: this.axo,
          fdsd: this.fdsd,
          fhst: this.fhst,
          fecha: this.fechaAsignacion,
          ejecutor: this.selectedEjecutor,
          mod: modMap[this.selectedApp],
          opc: 'M'
        }
      });
      alert('Folios asignados y practicados correctamente.');
    }
  }
};
</script>

<!-- EmpresasGenerarExcel.vue -->
<template>
  <div class="empresas-generar-excel">
    <h2>Generar Información Excel</h2>
    <form @submit.prevent="buscarDatos">
      <div>
        <label>Aplicación:</label>
        <select v-model="selectedApp" required>
          <option value="predial">Predial</option>
          <option value="licencias">Licencias</option>
          <option value="multas">Multas</option>
          <option value="anuncios">Anuncios</option>
        </select>
      </div>
      <div>
        <label>Fecha:</label>
        <input type="date" v-model="fechaExcel" required />
      </div>
      <div>
        <label>Empresa (Ejecutor):</label>
        <select v-model="selectedEjecutor" required>
          <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">
            {{ e.ejecutor }}
          </option>
        </select>
      </div>
      <button type="submit">Buscar</button>
    </form>
    <div v-if="datos.length">
      <h3>Datos Principales</h3>
      <table>
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in datos" :key="idx">
            <td v-for="col in columns" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="exportarExcel">Exportar a Excel</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import * as XLSX from 'xlsx';
export default {
  name: 'EmpresasGenerarExcel',
  data() {
    return {
      selectedApp: 'predial',
      fechaExcel: '',
      selectedEjecutor: '',
      ejecutores: [],
      datos: [],
      columns: []
    };
  },
  created() {
    this.loadEjecutores();
  },
  methods: {
    async loadEjecutores() {
      const { data } = await axios.post('/api/execute', {
        eRequest: { action: 'get_ejecutores' }
      });
      this.ejecutores = data.eResponse.data;
    },
    async buscarDatos() {
      const actionMap = {
        predial: 'get_predial_principal',
        licencias: 'get_licencias_principal',
        multas: 'get_multas_principal',
        anuncios: 'get_anuncios_principal'
      };
      const { data } = await axios.post('/api/execute', {
        eRequest: {
          action: actionMap[this.selectedApp],
          cveejecutor: this.selectedEjecutor,
          fecha: this.fechaExcel
        }
      });
      this.datos = data.eResponse.data;
      this.columns = this.datos.length ? Object.keys(this.datos[0]) : [];
    },
    exportarExcel() {
      const ws = XLSX.utils.json_to_sheet(this.datos);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Datos');
      XLSX.writeFile(wb, `Export_${this.selectedApp}_${this.selectedEjecutor}_${this.fechaExcel}.xlsx`);
    }
  }
};
</script>
