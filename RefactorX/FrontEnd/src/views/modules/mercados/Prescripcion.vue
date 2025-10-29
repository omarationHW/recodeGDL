<template>
  <div class="module-view">
    <h1>Prescripción de Adeudos de Energía Eléctrica</h1>
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Prescripción de Adeudos</span>
    </nav>
    <form @submit.prevent="buscarLocal">
      <div class="form-row">
        <label>Mercado:</label>
        <select v-model="form.mercado" @change="onMercadoChange">
          <option v-for="m in mercados" :key="m.id_energia" :value="m">
            {{ m.oficina }} - {{ m.num_mercado_nvo }} - {{ m.categoria }} - {{ m.descripcion }}
          </option>
        </select>
        <label>Sección:</label>
        <select v-model="form.seccion">
          <option v-for="s in secciones" :key="s.seccion" :value="s.seccion">{{ s.seccion }}</option>
        </select>
        <label>Local:</label>
        <input v-model="form.local" type="number" min="1" required />
        <label>Letra:</label>
        <input v-model="form.letra_local" maxlength="2" />
        <label>Bloque:</label>
        <input v-model="form.bloque" maxlength="2" />
        <label>Movimiento:</label>
        <select v-model="form.movimiento">
          <option value="Prescripcion">Prescripción</option>
          <option value="Condonacion">Condonación</option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="local">
      <div class="local-info">
        <strong>Nombre:</strong> {{ local.nombre }}<br />
        <strong>Adicionales:</strong> {{ local.local_adicional }}
      </div>
      <div class="oficio-row">
        <label>Oficio:</label>
        <input v-model="oficio" maxlength="13" placeholder="LLL/9999/9999" />
      </div>
      <div class="grids-row">
        <div class="adeudos-grid">
          <h2>Adeudos</h2>
          <table>
            <thead>
              <tr>
                <th>Año</th><th>Mes</th><th>Consumo</th><th>Cantidad</th><th>Importe</th><th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(a, idx) in adeudos" :key="a.id_adeudo_energia">
                <td>{{ a.axo }}</td>
                <td>{{ a.periodo }}</td>
                <td>{{ a.cve_consumo }}</td>
                <td>{{ a.cantidad }}</td>
                <td>{{ a.importe }}</td>
                <td><input type="checkbox" v-model="selectedAdeudos" :value="a" /></td>
              </tr>
            </tbody>
          </table>
          <button @click="prescribirAdeudos" :disabled="selectedAdeudos.length === 0 || !oficio">Prescribir</button>
        </div>
        <div class="prescripcion-grid">
          <h2>{{ form.movimiento === 'Prescripcion' ? 'Prescripción' : 'Condonación' }}</h2>
          <table>
            <thead>
              <tr>
                <th>Año</th><th>Mes</th><th>Consumo</th><th>Cantidad</th><th>Importe</th><th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(p, idx) in prescripcion" :key="p.id_cancelacion">
                <td>{{ p.axo }}</td>
                <td>{{ p.periodo }}</td>
                <td>{{ p.cve_consumo }}</td>
                <td>{{ p.cantidad }}</td>
                <td>{{ p.importe }}</td>
                <td><input type="checkbox" v-model="selectedPrescripcion" :value="p" /></td>
              </tr>
            </tbody>
          </table>
          <button @click="quitarPrescripcion" :disabled="selectedPrescripcion.length === 0">Quitar</button>
        </div>
      </div>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'PrescripcionPage',
  data() {
    return {
      mercados: [],
      secciones: [],
      form: {
        mercado: null,
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        movimiento: 'Prescripcion'
      },
      local: null,
      oficio: '',
      adeudos: [],
      prescripcion: [],
      selectedAdeudos: [],
      selectedPrescripcion: [],
      error: '',
      success: ''
    };
  },
  created() {
    this.fetchCatalogos();
  },
  methods: {
    async fetchCatalogos() {
      // Fetch mercados
      let res = await this.api('catalogo_mercados', {});
      if (res.status === 'success') this.mercados = res.data;
      res = await this.api('catalogo_secciones', {});
      if (res.status === 'success') this.secciones = res.data;
    },
    async buscarLocal() {
      this.error = '';
      this.success = '';
      this.local = null;
      this.adeudos = [];
      this.prescripcion = [];
      this.selectedAdeudos = [];
      this.selectedPrescripcion = [];
      if (!this.form.mercado) {
        this.error = 'Seleccione un mercado.';
        return;
      }
      const req = {
        oficina: this.form.mercado.oficina,
        num_mercado: this.form.mercado.num_mercado_nvo,
        categoria: this.form.mercado.categoria,
        seccion: this.form.seccion,
        local: this.form.local,
        letra_local: this.form.letra_local,
        bloque: this.form.bloque
      };
      let res = await this.api('buscar_local', req);
      if (res.status === 'success') {
        this.local = res.data;
        await this.cargarAdeudosPrescripcion();
      } else {
        this.error = res.message;
      }
    },
    async cargarAdeudosPrescripcion() {
      if (!this.local) return;
      let res = await this.api('listar_adeudos', { id_energia: this.local.id_energia });
      if (res.status === 'success') this.adeudos = res.data;
      res = await this.api('listar_prescripcion', { id_energia: this.local.id_energia });
      if (res.status === 'success') this.prescripcion = res.data;
    },
    async prescribirAdeudos() {
      if (!this.oficio) {
        this.error = 'Debe capturar el número de oficio.';
        return;
      }
      if (this.selectedAdeudos.length === 0) {
        this.error = 'Seleccione al menos un adeudo.';
        return;
      }
      let res = await this.api('prescribir_adeudos', {
        id_energia: this.local.id_energia,
        adeudos: this.selectedAdeudos,
        oficio: this.oficio,
        movimiento: this.form.movimiento
      });
      if (res.status === 'success') {
        this.success = res.message;
        await this.cargarAdeudosPrescripcion();
      } else {
        this.error = res.message;
      }
    },
    async quitarPrescripcion() {
      if (this.selectedPrescripcion.length === 0) {
        this.error = 'Seleccione al menos una prescripción.';
        return;
      }
      let res = await this.api('quitar_prescripcion', {
        id_energia: this.local.id_energia,
        prescripciones: this.selectedPrescripcion
      });
      if (res.status === 'success') {
        this.success = res.message;
        await this.cargarAdeudosPrescripcion();
      } else {
        this.error = res.message;
      }
    },
    async api(action, data) {
      // Simulación de llamada API
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, data, user: { id: 1 } } })
        });
        const json = await resp.json();
        return json.eResponse;
      } catch (e) {
        return { status: 'error', message: e.message };
      }
    },
    onMercadoChange() {
      // Reset seccion/local al cambiar mercado
      this.form.seccion = '';
      this.form.local = '';
      this.form.letra_local = '';
      this.form.bloque = '';
    }
  }
};
</script>

<style scoped>
.prescripcion-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.local-info {
  margin: 1rem 0;
  font-size: 1.1em;
}
.oficio-row {
  margin-bottom: 1rem;
}
.grids-row {
  display: flex;
  gap: 2rem;
}
.adeudos-grid, .prescripcion-grid {
  flex: 1;
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 1px 4px #eee;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
th, td {
  border: 1px solid #ddd;
  padding: 0.4rem 0.6rem;
  text-align: left;
}
th {
  background: #f0f0f0;
}
.error {
  color: #b00;
  margin-top: 1rem;
}
.success {
  color: #080;
  margin-top: 1rem;
}
</style>
