<template>
  <div class="energia-modif-page">
    <h2>Cambios de Energía Eléctrica</h2>
    <form @submit.prevent="onBuscar" class="form-buscar">
      <div class="form-row">
        <label class="municipal-form-label">Recaudadora</label>
        <select v-model="form.oficina" required>
          <option v-for="rec in catalogos.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
        <label class="municipal-form-label">Mercado</label>
        <input v-model="form.num_mercado" type="number" min="1" required />
        <label class="municipal-form-label">Categoria</label>
        <input v-model="form.categoria" type="number" min="1" required />
        <label class="municipal-form-label">Sección</label>
        <select v-model="form.seccion" required>
          <option v-for="sec in catalogos.secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }}</option>
        </select>
        <label class="municipal-form-label">Local</label>
        <input v-model="form.local" type="number" min="1" required />
        <label class="municipal-form-label">Letra</label>
        <input v-model="form.letra_local" maxlength="1" />
        <label class="municipal-form-label">Bloque</label>
        <input v-model="form.bloque" maxlength="1" />
      </div>
      <div class="form-row">
        <label class="municipal-form-label">Movimiento</label>
        <select v-model="form.movimiento" required>
          <option v-for="mov in catalogos.movimientos" :key="mov.value" :value="mov.value">{{ mov.label }}</option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="energia" class="form-modif">
      <h3>Datos de Energía</h3>
      <form @submit.prevent="onModificar">
        <div class="form-row">
          <label class="municipal-form-label">Control Mercado</label>
          <input v-model="energia.id_local" disabled />
          <label class="municipal-form-label">Control Energía</label>
          <input v-model="energia.id_energia" disabled />
        </div>
        <div class="form-row">
          <label class="municipal-form-label">Clave de Consumo</label>
          <select v-model="energia.cve_consumo" required>
            <option v-for="c in catalogos.consumos" :key="c.value" :value="c.value">{{ c.label }}</option>
          </select>
          <label class="municipal-form-label">Descripción Local</label>
          <input v-model="energia.local_adicional" maxlength="50" />
        </div>
        <div class="form-row">
          <label class="municipal-form-label">Cantidad</label>
          <input v-model.number="energia.cantidad" type="number" min="0.01" step="0.01" required />
          <label class="municipal-form-label">Vigencia</label>
          <input v-model="energia.vigencia" maxlength="1" required />
        </div>
        <div class="form-row">
          <label class="municipal-form-label">Fecha Alta</label>
          <input v-model="energia.fecha_alta" type="date" required />
          <label class="municipal-form-label">Fecha Baja</label>
          <input v-model="energia.fecha_baja" type="date" />
        </div>
        <div class="form-row" v-if="form.movimiento === 'B' || form.movimiento === 'D'">
          <label class="municipal-form-label">Periodo de Baja (Año)</label>
          <input v-model.number="periodo_baja_axo" type="number" min="1990" />
          <label class="municipal-form-label">Periodo de Baja (Mes/Bim)</label>
          <input v-model.number="periodo_baja_mes" type="number" min="1" max="12" />
        </div>
        <div class="form-row">
          <button type="submit">Modificar</button>
        </div>
      </form>
    </div>
    <div v-if="message" :class="{'error': !success, 'success': success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'EnergiaModifPage',
  data() {
    return {
      catalogos: {
        recaudadoras: [],
        secciones: [],
        movimientos: [],
        consumos: []
      },
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        movimiento: ''
      },
      energia: null,
      periodo_baja_axo: '',
      periodo_baja_mes: '',
      message: '',
      success: true
    };
  },
  created() {
    this.loadCatalogos();
  },
  methods: {
    async loadCatalogos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalogos' } })
      });
      const json = await res.json();
      if (json.eResponse.status === 'ok') {
        this.catalogos = json.eResponse.data;
      }
    },
    async onBuscar() {
      this.message = '';
      this.energia = null;
      const payload = {
        ...this.form,
        movimiento: this.form.movimiento
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'buscar', data: payload } })
      });
      const json = await res.json();
      if (json.eResponse.status === 'ok') {
        this.energia = json.eResponse.data;
        this.success = true;
      } else {
        this.message = json.eResponse.message;
        this.success = false;
      }
    },
    async onModificar() {
      this.message = '';
      const payload = {
        ...this.energia,
        movimiento: this.form.movimiento,
        usuario_id: 1, // TODO: obtener usuario real
        periodo_baja_axo: this.periodo_baja_axo,
        periodo_baja_mes: this.periodo_baja_mes
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'modificar', data: payload } })
      });
      const json = await res.json();
      this.message = json.eResponse.message;
      this.success = json.eResponse.status === 'ok';
      if (json.eResponse.status === 'ok') {
        this.energia = null;
        this.periodo_baja_axo = '';
        this.periodo_baja_mes = '';
      }
    }
  }
};
</script>

<style scoped>
.energia-modif-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
  margin-bottom: 1em;
}
label {
  min-width: 120px;
  font-weight: bold;
}
input, select {
  min-width: 120px;
  padding: 0.3em;
}
button {
  padding: 0.5em 1.5em;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.error {
  color: #b71c1c;
  margin-top: 1em;
}
.success {
  color: #388e3c;
  margin-top: 1em;
}
</style>
