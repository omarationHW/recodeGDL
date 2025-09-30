<template>
  <div class="etiquetas-page">
    <h1>Catálogo de Etiquetas</h1>
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Catálogos</span> &gt; <span>Etiquetas</span>
    </div>
    <div class="form-section">
      <label for="tabla">Tabla:</label>
      <select v-model="selectedTabla" @change="onTablaChange">
        <option v-for="t in tablas" :key="t.cve_tab" :value="t.cve_tab">
          {{ t.cve_tab }} - {{ t.nombre }}
        </option>
      </select>
    </div>
    <form @submit.prevent="onSubmit">
      <div class="form-grid">
        <div>
          <label>Abreviatura</label>
          <input v-model="form.abreviatura" maxlength="4" />
        </div>
        <div>
          <label>Control</label>
          <input v-model="form.etiq_control" maxlength="20" />
        </div>
        <div>
          <label>Concesionario</label>
          <input v-model="form.concesionario" maxlength="20" />
        </div>
        <div>
          <label>Ubicación</label>
          <input v-model="form.ubicacion" maxlength="20" />
        </div>
        <div>
          <label>Superficie</label>
          <input v-model="form.superficie" maxlength="20" />
        </div>
        <div>
          <label>Fecha Inicio</label>
          <input v-model="form.fecha_inicio" maxlength="20" />
        </div>
        <div>
          <label>Fecha Fin</label>
          <input v-model="form.fecha_fin" maxlength="20" />
        </div>
        <div>
          <label>Recaudadora</label>
          <input v-model="form.recaudadora" maxlength="20" />
        </div>
        <div>
          <label>Sector</label>
          <input v-model="form.sector" maxlength="20" />
        </div>
        <div>
          <label>Zona</label>
          <input v-model="form.zona" maxlength="20" />
        </div>
        <div>
          <label>Licencia</label>
          <input v-model="form.licencia" maxlength="20" />
        </div>
        <div>
          <label>Fecha Cancelación</label>
          <input v-model="form.fecha_cancelacion" maxlength="20" />
        </div>
        <div>
          <label>Unidad</label>
          <input v-model="form.unidad" maxlength="20" />
        </div>
        <div>
          <label>Categoría</label>
          <input v-model="form.categoria" maxlength="20" />
        </div>
        <div>
          <label>Sección</label>
          <input v-model="form.seccion" maxlength="20" />
        </div>
        <div>
          <label>Bloque</label>
          <input v-model="form.bloque" maxlength="20" />
        </div>
        <div>
          <label>Nombre Comercial</label>
          <input v-model="form.nombre_comercial" maxlength="20" />
        </div>
        <div>
          <label>Lugar</label>
          <input v-model="form.lugar" maxlength="20" />
        </div>
        <div>
          <label>Observaciones</label>
          <input v-model="form.obs" maxlength="20" />
        </div>
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="!canUpdate">Actualizar</button>
        <button type="button" @click="onCancel">Cancelar</button>
      </div>
      <div v-if="message" :class="{'success': success, 'error': !success}">
        {{ message }}
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'EtiquetasPage',
  data() {
    return {
      tablas: [],
      selectedTabla: '',
      etiquetas: [],
      form: {
        abreviatura: '',
        etiq_control: '',
        concesionario: '',
        ubicacion: '',
        superficie: '',
        fecha_inicio: '',
        fecha_fin: '',
        recaudadora: '',
        sector: '',
        zona: '',
        licencia: '',
        fecha_cancelacion: '',
        unidad: '',
        categoria: '',
        seccion: '',
        bloque: '',
        nombre_comercial: '',
        lugar: '',
        obs: ''
      },
      canUpdate: false,
      message: '',
      success: false
    };
  },
  created() {
    this.fetchTablas();
  },
  methods: {
    async fetchTablas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_tablas' })
      });
      const data = await res.json();
      if (data.success) {
        this.tablas = data.data;
        if (this.tablas.length > 0) {
          this.selectedTabla = this.tablas[0].cve_tab;
          this.onTablaChange();
        }
      }
    },
    async onTablaChange() {
      if (!this.selectedTabla) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_etiquetas', params: { cve_tab: this.selectedTabla } })
      });
      const data = await res.json();
      if (data.success && data.data.length > 0) {
        Object.assign(this.form, data.data[0]);
        this.canUpdate = true;
      } else {
        // Limpiar formulario
        Object.keys(this.form).forEach(k => this.form[k] = '');
        this.canUpdate = false;
      }
      this.message = '';
    },
    async onSubmit() {
      if (!this.selectedTabla) return;
      const params = { ...this.form, cve_tab: this.selectedTabla };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'update_etiquetas', params })
      });
      const data = await res.json();
      this.success = data.success;
      this.message = data.message || (data.success ? 'Actualización exitosa' : 'Error al actualizar');
      if (data.success) {
        this.onTablaChange();
      }
    },
    onCancel() {
      this.onTablaChange();
      this.message = '';
    }
  }
};
</script>

<style scoped>
.etiquetas-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.form-section {
  margin-bottom: 1.5rem;
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}
.form-actions {
  margin-top: 2rem;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>
