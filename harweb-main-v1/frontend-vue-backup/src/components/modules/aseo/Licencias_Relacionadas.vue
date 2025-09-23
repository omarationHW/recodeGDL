<template>
  <div class="licencias-relacionadas-page">
    <div class="breadcrumbs">
      <span>Inicio</span> &gt; <span>Licencias Relacionadas</span>
    </div>
    <h1>Licencias Relacionadas</h1>
    <div class="search-panel">
      <label>Busqueda:</label>
      <select v-model="opcion" @change="onOpcionChange">
        <option value="0">Todas</option>
        <option value="1">Por Licencia</option>
        <option value="2">Por Contrato</option>
      </select>
      <input v-if="opcion == 1" v-model="numLicencia" type="number" placeholder="No. Licencia" />
      <input v-if="opcion == 2" v-model="numContrato" type="number" placeholder="No. Contrato" />
      <label v-if="opcion == 2">Tipo de Aseo:</label>
      <select v-if="opcion == 2" v-model="ctrolAseo">
        <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
          {{ t.ctrol_aseo }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
        </option>
      </select>
      <button @click="buscar">Buscar</button>
      <button @click="exportarExcel">Exportar Excel</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <table v-if="!loading && licencias.length" class="table table-striped">
      <thead>
        <tr>
          <th>Control Contrato</th>
          <th>Contrato</th>
          <th>Tipo</th>
          <th>Domicilio Recolección</th>
          <th>Empresa</th>
          <th>Representante</th>
          <th>Licencia</th>
          <th>Actividad</th>
          <th>Propietario</th>
          <th>Domicilio Licencia</th>
          <th>NumExt Prop.</th>
          <th>Ubicación Prop.</th>
          <th>NumExt. Ubic.</th>
          <th>Vig.</th>
          <th>Acción</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="lic in licencias" :key="lic.control_contrato + '-' + lic.num_licencia">
          <td>{{ lic.control_contrato }}</td>
          <td>{{ lic.num_contrato }}</td>
          <td>{{ lic.tipo_aseo }}</td>
          <td>{{ lic.domicilio_recoleccion_contrato }}</td>
          <td>{{ lic.empresa_contrato }}</td>
          <td>{{ lic.representante_contrato }}</td>
          <td>{{ lic.num_licencia }}</td>
          <td>{{ lic.actividad_licencia }}</td>
          <td>{{ lic.propietario_licencia }}</td>
          <td>{{ lic.domicilio_licencia }}</td>
          <td>{{ lic.numext_prop }}</td>
          <td>{{ lic.ubicacion_licencia }}</td>
          <td>{{ lic.numext_ubic }}</td>
          <td>{{ lic.vigencia_rel }}</td>
          <td>
            <button @click="desligarLicencia(lic)" :disabled="desligando">Desligar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="!loading && !licencias.length" class="no-data">No hay registros.</div>
  </div>
</template>

<script>
export default {
  name: 'LicenciasRelacionadasPage',
  data() {
    return {
      opcion: '0',
      numLicencia: '',
      numContrato: '',
      ctrolAseo: '',
      tiposAseo: [],
      licencias: [],
      loading: false,
      error: '',
      desligando: false
    };
  },
  created() {
    this.cargarTiposAseo();
  },
  methods: {
    async cargarTiposAseo() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'listar_tipos_aseo' })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.tiposAseo = data.data;
          if (this.tiposAseo.length) this.ctrolAseo = this.tiposAseo[0].ctrol_aseo;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    onOpcionChange() {
      this.numLicencia = '';
      this.numContrato = '';
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.licencias = [];
      let params = { opcion: this.opcion };
      if (this.opcion === '1') params.num_licencia = this.numLicencia;
      if (this.opcion === '2') {
        params.control_contrato = this.numContrato;
        params.ctrol_aseo = this.ctrolAseo;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'listar_licencias_relacionadas', params })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.licencias = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async desligarLicencia(lic) {
      if (!confirm('¿Desea desligar la licencia del contrato?')) return;
      this.desligando = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'desligar_licencia',
            params: {
              num_licencia: lic.num_licencia,
              control_contrato: lic.control_contrato
            }
          })
        });
        const data = await res.json();
        alert(data.message);
        if (data.status === 'success') {
          this.buscar();
        }
      } catch (e) {
        alert(e.message);
      } finally {
        this.desligando = false;
      }
    },
    exportarExcel() {
      // Exportar tabla a Excel (simple, para demo)
      let csv = '';
      const headers = [
        'Control Contrato','Contrato','Tipo','Domicilio Recolección','Empresa','Representante','Licencia','Actividad','Propietario','Domicilio Licencia','NumExt Prop.','Ubicación Prop.','NumExt. Ubic.','Vig.'
      ];
      csv += headers.join(',') + '\n';
      this.licencias.forEach(lic => {
        csv += [
          lic.control_contrato, lic.num_contrato, lic.tipo_aseo, lic.domicilio_recoleccion_contrato, lic.empresa_contrato, lic.representante_contrato, lic.num_licencia, lic.actividad_licencia, lic.propietario_licencia, lic.domicilio_licencia, lic.numext_prop, lic.ubicacion_licencia, lic.numext_ubic, lic.vigencia_rel
        ].map(x => '"'+(x||'')+'"').join(',') + '\n';
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'licencias_relacionadas.csv';
      a.click();
      URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.licencias-relacionadas-page {
  max-width: 98vw;
  margin: 0 auto;
  padding: 1.5rem;
}
.breadcrumbs {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.search-panel {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #ddd;
  padding: 0.4rem 0.6rem;
}
.table th {
  background: #f5f5f5;
}
.loading { color: #007bff; }
.error { color: #c00; }
.no-data { color: #888; margin-top: 1rem; }
</style>
