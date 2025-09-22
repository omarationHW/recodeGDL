<template>
  <div class="contratos-upd-page">
    <h1>Actualización de Contratos</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSearch">
        <div class="form-row">
          <label>No. Contrato</label>
          <input v-model="form.num_contrato" type="number" required />
        </div>
        <div class="form-row">
          <label>Tipo de Aseo</label>
          <select v-model="form.ctrol_aseo" required>
            <option v-for="ta in catalogs.tipoAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
              {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
            </option>
          </select>
        </div>
        <button type="submit">Buscar Contrato</button>
      </form>
      <div v-if="contrato">
        <h2>Datos del Contrato</h2>
        <form @submit.prevent="onUpdate">
          <div class="form-row">
            <label>Cantidad de Recolección</label>
            <input v-model.number="contrato.cantidad_recolec" type="number" min="1" required />
          </div>
          <div class="form-row">
            <label>Domicilio</label>
            <input v-model="contrato.domicilio" type="text" maxlength="80" required />
          </div>
          <div class="form-row">
            <label>Sector</label>
            <select v-model="contrato.sector" required>
              <option v-for="s in catalogs.sectores" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>
          <div class="form-row">
            <label>Zona</label>
            <select v-model="contrato.ctrol_zona" required>
              <option v-for="z in catalogs.zonas" :key="z.ctrol_zona" :value="z.ctrol_zona">
                {{ z.ctrol_zona }} - {{ z.zona }} - {{ z.sub_zona }} - {{ z.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-row">
            <label>Recaudadora</label>
            <select v-model="contrato.id_rec" required>
              <option v-for="r in catalogs.recaudadoras" :key="r.id_rec" :value="r.id_rec">
                {{ r.id_rec }} - {{ r.recaudadora }}
              </option>
            </select>
          </div>
          <div class="form-row">
            <label>Inicio de Obligación</label>
            <input v-model="contrato.aso_mes_oblig" type="date" required />
          </div>
          <div class="form-row">
            <label>Documento</label>
            <input v-model="form.documento" type="text" required />
          </div>
          <div class="form-row">
            <label>Descripción Documento</label>
            <textarea v-model="form.descripcion_docto" required></textarea>
          </div>
          <div class="form-row">
            <label>Usuario</label>
            <input v-model.number="form.usuario" type="number" required />
          </div>
          <button type="submit">Actualizar Contrato</button>
        </form>
      </div>
      <div v-if="message" :class="{'success': status==='ok', 'error': status==='error'}">
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdPage',
  data() {
    return {
      loading: true,
      catalogs: {
        tipoAseo: [],
        zonas: [],
        recaudadoras: [],
        sectores: []
      },
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        documento: '',
        descripcion_docto: '',
        usuario: ''
      },
      contrato: null,
      message: '',
      status: ''
    }
  },
  mounted() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'catalogs', data: {} } })
        });
        const json = await res.json();
        if (json.eResponse.status === 'ok') {
          this.catalogs = json.eResponse.data;
        }
      } catch (e) {
        this.message = 'Error cargando catálogos';
        this.status = 'error';
      }
      this.loading = false;
    },
    async onSearch() {
      this.message = '';
      this.status = '';
      this.contrato = null;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'load', data: { num_contrato: this.form.num_contrato, ctrol_aseo: this.form.ctrol_aseo } } })
        });
        const json = await res.json();
        if (json.eResponse.status === 'ok') {
          this.contrato = json.eResponse.data.contrato;
          // Actualizar catálogos si vienen nuevos
          if (json.eResponse.data.tipoAseo) this.catalogs.tipoAseo = json.eResponse.data.tipoAseo;
          if (json.eResponse.data.zonas) this.catalogs.zonas = json.eResponse.data.zonas;
          if (json.eResponse.data.recaudadoras) this.catalogs.recaudadoras = json.eResponse.data.recaudadoras;
          if (json.eResponse.data.sectores) this.catalogs.sectores = json.eResponse.data.sectores;
        } else {
          this.message = json.eResponse.message;
          this.status = 'error';
        }
      } catch (e) {
        this.message = 'Error buscando contrato';
        this.status = 'error';
      }
      this.loading = false;
    },
    async onUpdate() {
      this.message = '';
      this.status = '';
      this.loading = true;
      try {
        const payload = {
          control_contrato: this.contrato.control_contrato,
          cantidad_recolec: this.contrato.cantidad_recolec,
          domicilio: this.contrato.domicilio,
          sector: this.contrato.sector,
          ctrol_zona: this.contrato.ctrol_zona,
          id_rec: this.contrato.id_rec,
          aso_mes_oblig: this.contrato.aso_mes_oblig,
          documento: this.form.documento,
          descripcion_docto: this.form.descripcion_docto,
          usuario: this.form.usuario
        };
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'update', data: payload } })
        });
        const json = await res.json();
        this.message = json.eResponse.message;
        this.status = json.eResponse.status;
        if (json.eResponse.status === 'ok') {
          this.contrato = null;
        }
      } catch (e) {
        this.message = 'Error actualizando contrato';
        this.status = 'error';
      }
      this.loading = false;
    }
  }
}
</script>

<style scoped>
.contratos-upd-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
label {
  font-weight: bold;
  margin-bottom: 0.2rem;
}
input, select, textarea {
  padding: 0.4rem;
  font-size: 1rem;
}
button {
  margin-top: 1rem;
  padding: 0.6rem 1.2rem;
  font-size: 1rem;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
button:hover {
  background: #125ea2;
}
.success {
  color: green;
  margin-top: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.loading {
  color: #1976d2;
  font-weight: bold;
}
</style>
