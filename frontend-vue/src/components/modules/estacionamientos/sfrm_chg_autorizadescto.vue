<template>
  <div class="chg-autorizadescto-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Autorización de Descuento</li>
      </ol>
    </nav>
    <h2>Autorización de Descuento</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarFolios">
          <div class="form-row align-items-end">
            <div class="col-auto">
              <label for="placa">Placa</label>
              <input v-model="placa" id="placa" class="form-control" maxlength="7" required />
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div v-if="foliosHisto.length" class="mb-4">
      <h5>Folios Históricos</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Fecha folio</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(folio, idx) in foliosHisto" :key="idx" :class="{ 'table-active': idx === selectedFolioIdx }">
            <td>{{ folio.axo }}</td>
            <td>{{ folio.folio }}</td>
            <td>{{ folio.placa }}</td>
            <td>{{ formatDate(folio.fecha_folio) }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="selectFolio(idx)">Ver detalles</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="foliosFree.length">
      <h5>Descuentos Otorgados</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Año</th>
            <th>Folio</th>
            <th>Fecha otorga</th>
            <th>Descuento Otorgado</th>
            <th>Porcentaje cobrado</th>
            <th>Fecha captura</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(free, idx) in foliosFree" :key="idx">
            <td>{{ free.axo }}</td>
            <td>{{ free.folio }}</td>
            <td>{{ formatDate(free.fecha_otorga) }}</td>
            <td>{{ free.obs }}</td>
            <td>{{ free.porc_cobro }}</td>
            <td>{{ formatDate(free.fec_cap) }}</td>
            <td>
              <button class="btn btn-warning btn-sm" @click="cambiarATesorero(free.axo, free.folio)">
                Cambiar a Tesorero
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'SfrmChgAutorizadescto',
  data() {
    return {
      placa: '',
      foliosHisto: [],
      foliosFree: [],
      selectedFolioIdx: null,
      message: '',
      success: true
    };
  },
  methods: {
    async buscarFolios() {
      this.message = '';
      this.foliosHisto = [];
      this.foliosFree = [];
      this.selectedFolioIdx = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'buscar_folios_histo',
            params: { placa: this.placa }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.foliosHisto = data.eResponse.data;
          if (this.foliosHisto.length) {
            this.selectFolio(0);
          } else {
            this.message = 'No se encontraron folios para la placa ingresada.';
            this.success = false;
          }
        } else {
          this.message = data.eResponse.message || 'Error al buscar folios.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    },
    async selectFolio(idx) {
      this.selectedFolioIdx = idx;
      const folio = this.foliosHisto[idx];
      this.foliosFree = [];
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'buscar_folios_free',
            params: { axo: folio.axo, folio: folio.folio }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.foliosFree = data.eResponse.data;
        } else {
          this.message = data.eResponse.message || 'Error al buscar descuentos.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    },
    async cambiarATesorero(axo, folio) {
      if (!confirm('¿Está seguro de cambiar el descuento a "Tesorero"?')) return;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'cambiar_a_tesorero',
            params: { axo, folio }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.message = 'Descuento cambiado a "Tesorero" correctamente.';
          this.success = true;
          // Refrescar la tabla de descuentos
          this.selectFolio(this.selectedFolioIdx);
        } else {
          this.message = data.eResponse.message || 'Error al cambiar a Tesorero.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.chg-autorizadescto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
